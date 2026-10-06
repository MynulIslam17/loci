import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loci/core/config/app_secrets.dart';
import 'package:loci/features/location/data/models/direction_model.dart';
import 'package:loci/features/location/data/models/navigation_step_model.dart';

export 'package:loci/features/location/data/models/direction_model.dart';
export 'package:loci/features/location/data/models/navigation_step_model.dart';

class RouteDirectionException implements Exception {
  const RouteDirectionException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Requests actual road geometry. A missing route is reported to the UI instead
/// of drawing a straight line that could be mistaken for a navigable road.
class RouteDirectionService {
  RouteDirectionService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? AppSecrets.googleMapsApiKey;

  static final RouteDirectionService instance = RouteDirectionService();
  static final Uri _endpoint = Uri.parse(
    'https://routes.googleapis.com/directions/v2:computeRoutes',
  );
  final http.Client _client;
  final String _apiKey;

  Future<RouteDirectionResult> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'walking',
  }) async {
    if (!_validCoordinate(originLat, originLng) ||
        !_validCoordinate(destLat, destLng)) {
      throw const RouteDirectionException(
        'This location has invalid coordinates.',
      );
    }
    if (_apiKey.trim().isEmpty || _apiKey.startsWith('YOUR_')) {
      throw const RouteDirectionException('Map routing is not configured.');
    }

    final travelMode = switch (mode) {
      'walking' => 'WALK',
      'bicycling' => 'BICYCLE',
      'twoWheeler' => 'TWO_WHEELER',
      'driving' => 'DRIVE',
      _ => throw const RouteDirectionException('Unsupported travel mode.'),
    };
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,'
          'routes.legs.steps.distanceMeters,routes.legs.steps.startLocation,'
          'routes.legs.steps.navigationInstruction',
    };
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      headers['X-Ios-Bundle-Identifier'] = 'ui.neatboutique.jacobi';
    }

    final body = jsonEncode(<String, Object>{
      'origin': _waypoint(originLat, originLng),
      'destination': _waypoint(destLat, destLng),
      'travelMode': travelMode,
      'polylineQuality': 'HIGH_QUALITY',
      if (travelMode == 'DRIVE' || travelMode == 'TWO_WHEELER')
        'routingPreference': 'TRAFFIC_AWARE',
      'languageCode': 'en-US',
      'units': 'METRIC',
    });

    late final http.Response response;
    try {
      response = await _client
          .post(_endpoint, headers: headers, body: body)
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const RouteDirectionException('Routing timed out. Try again.');
    } catch (_) {
      throw const RouteDirectionException(
        'Could not connect to routing. Check your connection.',
      );
    }

    if (response.statusCode != 200) {
      throw RouteDirectionException(
        response.statusCode == 403
            ? 'Routing access is blocked. Check the Routes API key and restrictions.'
            : 'Could not calculate a route. Try again.',
      );
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        throw const RouteDirectionException(
          'No route is available for this travel mode.',
        );
      }
      final route = routes.first as Map<String, dynamic>;
      final polyline =
          (route['polyline'] as Map<String, dynamic>?)?['encodedPolyline']
              as String?;
      if (polyline == null || polyline.isEmpty) {
        throw const RouteDirectionException(
          'The route has no road geometry. Try again.',
        );
      }
      final points = decodePolyline(polyline);
      if (points.length < 2) {
        throw const RouteDirectionException(
          'The route has no road geometry. Try again.',
        );
      }

      final steps = <RouteStep>[];
      final legs = route['legs'] as List<dynamic>?;
      for (final leg in legs ?? const <dynamic>[]) {
        if (leg is! Map<String, dynamic>) continue;
        for (final raw
            in (leg['steps'] as List<dynamic>? ?? const <dynamic>[])) {
          if (raw is! Map<String, dynamic>) continue;
          final start =
              (raw['startLocation'] as Map<String, dynamic>?)?['latLng']
                  as Map<String, dynamic>?;
          final lat = (start?['latitude'] as num?)?.toDouble();
          final lng = (start?['longitude'] as num?)?.toDouble();
          if (lat == null || lng == null || !_validCoordinate(lat, lng)) {
            continue;
          }
          final navigation =
              raw['navigationInstruction'] as Map<String, dynamic>?;
          steps.add(
            RouteStep(
              instruction:
                  navigation?['instructions']?.toString() ?? 'Continue',
              maneuver:
                  navigation?['maneuver']?.toString().toLowerCase() ??
                  'straight',
              distanceMeters: (raw['distanceMeters'] as num?)?.toDouble() ?? 0,
              startLocation: LatLng(lat, lng),
            ),
          );
        }
      }

      final seconds = double.tryParse(
        route['duration']?.toString().replaceAll('s', '') ?? '',
      );
      return RouteDirectionResult(
        polylinePoints: points,
        distanceInMeters: (route['distanceMeters'] as num?)?.toDouble() ?? 0,
        durationText: seconds == null ? null : _formatDuration(seconds),
        durationSeconds: seconds,
        steps: steps,
        source: 'google_routes_v2',
      );
    } on RouteDirectionException {
      rethrow;
    } catch (_) {
      throw const RouteDirectionException(
        'The routing response could not be read. Try again.',
      );
    }
  }

  static Map<String, Object> _waypoint(double lat, double lng) =>
      <String, Object>{
        'location': <String, Object>{
          'latLng': <String, double>{'latitude': lat, 'longitude': lng},
        },
      };

  static bool _validCoordinate(double lat, double lng) =>
      lat.isFinite &&
      lng.isFinite &&
      lat >= -90 &&
      lat <= 90 &&
      lng >= -180 &&
      lng <= 180;

  static String _formatDuration(double seconds) {
    final minutes = (seconds / 60).ceil().clamp(1, 1000000);
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours hr' : '$hours hr $rest min';
  }

  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;
    int nextValue() {
      var shift = 0;
      var result = 0;
      while (true) {
        if (index >= encoded.length || shift > 30) {
          throw const FormatException('Invalid encoded polyline');
        }
        final value = encoded.codeUnitAt(index++) - 63;
        result |= (value & 0x1f) << shift;
        if (value < 0x20) break;
        shift += 5;
      }
      return result.isOdd ? ~(result >> 1) : result >> 1;
    }

    while (index < encoded.length) {
      lat += nextValue();
      lng += nextValue();
      final latitude = lat / 1e5;
      final longitude = lng / 1e5;
      if (!_validCoordinate(latitude, longitude)) {
        throw const FormatException('Invalid polyline coordinates');
      }
      points.add(LatLng(latitude, longitude));
    }
    return points;
  }
}
