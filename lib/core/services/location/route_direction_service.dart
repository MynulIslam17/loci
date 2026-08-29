import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loci/core/config/app_secrets.dart';
import 'package:logger/logger.dart';

/// Single turn-by-turn route step/maneuver
class RouteStep {
  final String instruction;
  final String maneuver; // 'turn-left', 'turn-right', 'straight', 'uturn', 'left', 'right', etc.
  final double distanceMeters;
  final LatLng startLocation;

  RouteStep({
    required this.instruction,
    required this.maneuver,
    required this.distanceMeters,
    required this.startLocation,
  });
}

/// Result containing decoded polyline coordinates, total distance in meters, duration, and steps.
class RouteDirectionResult {
  final List<LatLng> polylinePoints;
  final double distanceInMeters;
  final String? durationText;
  final List<RouteStep> steps;
  final String source; // 'google' or 'osrm' or 'straight_line'

  RouteDirectionResult({
    required this.polylinePoints,
    required this.distanceInMeters,
    this.durationText,
    this.steps = const [],
    required this.source,
  });
}

/// Service to fetch routing polyline and directions between two points.
class RouteDirectionService {
  RouteDirectionService._();
  static final RouteDirectionService instance = RouteDirectionService._();
  final Logger _logger = Logger();

  /// Fetches route directions from origin to destination.
  Future<RouteDirectionResult> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving', // 'driving', 'walking', 'bicycling'
  }) async {
    // 1. Try Google Directions API if key is present
    if (AppSecrets.hasGoogleMapsApiKey) {
      try {
        final googleResult = await _fetchGoogleDirections(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          mode: mode,
        );
        if (googleResult != null && googleResult.polylinePoints.isNotEmpty) {
          return googleResult;
        }
      } catch (e) {
        _logger.w('Google Directions API failed, falling back to OSRM: $e');
      }
    }

    // 2. Fallback to OSRM (OpenStreetMap Routing)
    try {
      final osrmResult = await _fetchOsrmDirections(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        mode: mode,
      );
      if (osrmResult != null && osrmResult.polylinePoints.isNotEmpty) {
        return osrmResult;
      }
    } catch (e) {
      _logger.w('OSRM Directions failed: $e');
    }

    // 3. Last-resort fallback: Direct line
    return RouteDirectionResult(
      polylinePoints: [
        LatLng(originLat, originLng),
        LatLng(destLat, destLng),
      ],
      distanceInMeters: 0,
      durationText: null,
      steps: [
        RouteStep(
          instruction: 'Head towards destination',
          maneuver: 'straight',
          distanceMeters: 0,
          startLocation: LatLng(originLat, originLng),
        ),
      ],
      source: 'straight_line',
    );
  }

  /// Calls Google Maps Directions API
  Future<RouteDirectionResult?> _fetchGoogleDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String mode,
  }) async {
    final apiKey = AppSecrets.googleMapsApiKey;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&mode=$mode'
      '&key=$apiKey',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final overviewPolyline = route['overview_polyline']['points'] as String;
        final decodedPoints = decodePolyline(overviewPolyline);

        double distanceMeters = 0;
        String? duration;
        List<RouteStep> steps = [];

        final legs = route['legs'] as List?;
        if (legs != null && legs.isNotEmpty) {
          distanceMeters = (legs[0]['distance']['value'] as num?)?.toDouble() ?? 0;
          duration = legs[0]['duration']['text'] as String?;

          final rawSteps = legs[0]['steps'] as List?;
          if (rawSteps != null) {
            for (var s in rawSteps) {
              final htmlInst = s['html_instructions']?.toString() ?? '';
              final cleanInst = htmlInst
                  .replaceAll(RegExp(r'<[^>]*>'), ' ')
                  .replaceAll(RegExp(r'\s+'), ' ')
                  .trim();
              final maneuver = s['maneuver']?.toString() ?? 'straight';
              final dist = (s['distance']['value'] as num?)?.toDouble() ?? 0;
              final startLat = (s['start_location']['lat'] as num?)?.toDouble() ?? 0;
              final startLng = (s['start_location']['lng'] as num?)?.toDouble() ?? 0;

              steps.add(
                RouteStep(
                  instruction: cleanInst.isNotEmpty ? cleanInst : 'Continue straight',
                  maneuver: maneuver,
                  distanceMeters: dist,
                  startLocation: LatLng(startLat, startLng),
                ),
              );
            }
          }
        }

        return RouteDirectionResult(
          polylinePoints: decodedPoints,
          distanceInMeters: distanceMeters,
          durationText: duration,
          steps: steps,
          source: 'google',
        );
      }
    }
    return null;
  }

  /// Calls free OSRM Public Routing API
  Future<RouteDirectionResult?> _fetchOsrmDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String mode,
  }) async {
    final profile = mode == 'walking' ? 'foot' : (mode == 'bicycling' ? 'bike' : 'driving');
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '$originLng,$originLat;$destLng,$destLat'
      '?overview=full&geometries=geojson&steps=true',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final coordinates = route['geometry']['coordinates'] as List;

        final List<LatLng> points = coordinates.map<LatLng>((coord) {
          final lng = (coord[0] as num).toDouble();
          final lat = (coord[1] as num).toDouble();
          return LatLng(lat, lng);
        }).toList();

        final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
        final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0;
        final durationMins = (durationSeconds / 60).round();
        
        String durationText;
        if (durationMins <= 1) {
          durationText = '1 min';
        } else if (durationMins < 60) {
          durationText = '$durationMins min';
        } else {
          final hr = durationMins ~/ 60;
          final min = durationMins % 60;
          durationText = min == 0 ? '$hr hr' : '$hr hr $min min';
        }

        List<RouteStep> steps = [];
        final legs = route['legs'] as List?;
        if (legs != null && legs.isNotEmpty) {
          final rawSteps = legs[0]['steps'] as List?;
          if (rawSteps != null) {
            for (var s in rawSteps) {
              final name = s['name']?.toString() ?? '';
              final maneuverType = s['maneuver']?['type']?.toString() ?? 'straight';
              final modifier = s['maneuver']?['modifier']?.toString() ?? '';
              final dist = (s['distance'] as num?)?.toDouble() ?? 0;
              final loc = s['maneuver']?['location'] as List?;
              final startLng = loc != null && loc.isNotEmpty ? (loc[0] as num).toDouble() : 0.0;
              final startLat = loc != null && loc.length > 1 ? (loc[1] as num).toDouble() : 0.0;

              String instruction = maneuverType;
              if (modifier.isNotEmpty) {
                instruction = '$maneuverType $modifier';
              }
              if (name.isNotEmpty) {
                instruction += ' onto $name';
              }

              steps.add(
                RouteStep(
                  instruction: instruction,
                  maneuver: modifier.isNotEmpty ? modifier : maneuverType,
                  distanceMeters: dist,
                  startLocation: LatLng(startLat, startLng),
                ),
              );
            }
          }
        }

        return RouteDirectionResult(
          polylinePoints: points,
          distanceInMeters: distanceMeters,
          durationText: durationText,
          steps: steps,
          source: 'osrm',
        );
      }
    }
    return null;
  }

  /// Decodes a Google encoded polyline string into a list of [LatLng].
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
