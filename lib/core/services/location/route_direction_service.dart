import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  /// Fetches route directions from origin to destination using a 3-tier fallback chain:
  /// 1. Google Routes API (v2 - Modern, High Performance, Two-Wheeler support)
  /// 2. Google Directions API (v1 - Legacy fallback)
  /// 3. OSRM (Free OpenStreetMap routing fallback)
  /// 4. Straight line (Last resort)
  Future<RouteDirectionResult> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving', // 'driving', 'walking', 'bicycling', 'twoWheeler'
  }) async {
    debugPrint('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    debugPrint('┃          📍 [ROUTE DIRECTION SERVICE]                 ┃');
    debugPrint('┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫');
    debugPrint('┃ Origin: ($originLat, $originLng)');
    debugPrint('┃ Destination: ($destLat, $destLng)');
    debugPrint('┃ Travel Mode: $mode');
    debugPrint('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛');

    // 1. TIER 1: Try Modern Google Routes API (v2) if key is present
    if (AppSecrets.hasGoogleMapsApiKey) {
      debugPrint('🔑 Google Maps API Key: Present (...${AppSecrets.googleMapsApiKey.length > 5 ? AppSecrets.googleMapsApiKey.substring(AppSecrets.googleMapsApiKey.length - 4) : AppSecrets.googleMapsApiKey})');
      
      try {
        debugPrint('🚀 [Attempting Tier 1]: Google Routes API (v2)...');
        final routesV2Result = await _fetchGoogleRoutesApi(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          mode: mode,
        );
        if (routesV2Result != null && routesV2Result.polylinePoints.isNotEmpty) {
          debugPrint('\n=========================================================');
          debugPrint('🎯 [ACTIVE ENGINE]: 🌟 GOOGLE ROUTES API (v2) 🌟');
          debugPrint('📊 Points: ${routesV2Result.polylinePoints.length} | Distance: ${routesV2Result.distanceInMeters.toStringAsFixed(0)}m | Duration: ${routesV2Result.durationText} | Source: ${routesV2Result.source}');
          debugPrint('=========================================================\n');
          return routesV2Result;
        }
      } catch (e, st) {
        debugPrint('⚠️ [Google Routes API v2 Exception]: $e');
        _logger.w('Google Routes API v2 exception', error: e, stackTrace: st);
      }

      // 2. TIER 2: Fallback to Google Directions API (v1)
      try {
        debugPrint('🔄 [Attempting Tier 2]: Google Directions API (v1)...');
        final directionsV1Result = await _fetchGoogleDirections(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          mode: mode == 'twoWheeler' ? 'bicycling' : mode,
        );
        if (directionsV1Result != null && directionsV1Result.polylinePoints.isNotEmpty) {
          debugPrint('\n=========================================================');
          debugPrint('🎯 [ACTIVE ENGINE]: 🔹 GOOGLE DIRECTIONS API (v1) 🔹');
          debugPrint('📊 Points: ${directionsV1Result.polylinePoints.length} | Distance: ${directionsV1Result.distanceInMeters.toStringAsFixed(0)}m | Duration: ${directionsV1Result.durationText} | Source: ${directionsV1Result.source}');
          debugPrint('=========================================================\n');
          return directionsV1Result;
        }
      } catch (e, st) {
        debugPrint('⚠️ [Google Directions API v1 Exception]: $e');
        _logger.w('Google Directions API v1 exception', error: e, stackTrace: st);
      }
    } else {
      debugPrint('⚠️ [Google Maps API Key]: MISSING (AppSecrets.hasGoogleMapsApiKey == false)');
    }

    // 3. TIER 3: Fallback to OSRM (OpenStreetMap Free Routing API)
    debugPrint('🔄 [Attempting Tier 3]: OSRM (OpenStreetMap Free Routing API)...');
    try {
      final osrmResult = await _fetchOsrmDirections(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        mode: mode == 'twoWheeler' ? 'bicycling' : mode,
      );
      if (osrmResult != null && osrmResult.polylinePoints.isNotEmpty) {
        debugPrint('\n=========================================================');
        debugPrint('🎯 [ACTIVE ENGINE]: 🛡️ OSRM FREE ROUTING ENGINE 🛡️');
        debugPrint('📊 Points: ${osrmResult.polylinePoints.length} | Distance: ${osrmResult.distanceInMeters.toStringAsFixed(0)}m | Duration: ${osrmResult.durationText} | Source: ${osrmResult.source}');
        debugPrint('=========================================================\n');
        return osrmResult;
      }
    } catch (e) {
      debugPrint('❌ [OSRM Exception]: $e');
      _logger.w('OSRM Directions failed: $e');
    }

    // 4. TIER 4: Last-resort fallback: Direct line
    debugPrint('\n=========================================================');
    debugPrint('⚠️ [ACTIVE ENGINE]: ⚡ STRAIGHT LINE (Emergency Fallback) ⚡');
    debugPrint('=========================================================\n');
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

  /// Calls Google Routes API (v2) - High-performance computeRoutes
  Future<RouteDirectionResult?> _fetchGoogleRoutesApi({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String mode,
  }) async {
    final apiKey = AppSecrets.googleMapsApiKey;
    final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

    String travelMode = 'DRIVE';
    if (mode == 'walking') {
      travelMode = 'WALK';
    } else if (mode == 'bicycling') {
      travelMode = 'BICYCLE';
    } else if (mode == 'twoWheeler') {
      travelMode = 'TWO_WHEELER';
    }

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs.steps',
    };

    final body = json.encode({
      "origin": {
        "location": {
          "latLng": {
            "latitude": originLat,
            "longitude": originLng,
          }
        }
      },
      "destination": {
        "location": {
          "latLng": {
            "latitude": destLat,
            "longitude": destLng,
          }
        }
      },
      "travelMode": travelMode,
      "routingPreference": (travelMode == 'DRIVE' || travelMode == 'TWO_WHEELER')
          ? 'TRAFFIC_AWARE'
          : 'ROUTING_PREFERENCE_UNSPECIFIED',
      "computeAlternativeRoutes": false,
      "languageCode": "en-US",
      "units": "METRIC",
    });

    debugPrint('🌐 [Google Routes v2 Request]: $url (travelMode: $travelMode)');

    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 8));

    debugPrint('📡 [Google Routes v2 HTTP Status]: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'] as List?;

      if (routes != null && routes.isNotEmpty) {
        final route = routes[0];
        final encodedPolyline = route['polyline']?['encodedPolyline'] as String?;

        if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
          final decodedPoints = decodePolyline(encodedPolyline);
          final distanceMeters = (route['distanceMeters'] as num?)?.toDouble() ?? 0;

          final durationStr = route['duration']?.toString() ?? '';
          String? durationText;
          if (durationStr.endsWith('s')) {
            final seconds = int.tryParse(durationStr.replaceAll('s', '')) ?? 0;
            final mins = (seconds / 60).round();
            if (mins <= 1) {
              durationText = '1 min';
            } else if (mins < 60) {
              durationText = '$mins mins';
            } else {
              final hr = mins ~/ 60;
              final m = mins % 60;
              durationText = m == 0 ? '$hr hr' : '$hr hr $m min';
            }
          }

          List<RouteStep> steps = [];
          final legs = route['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            final rawSteps = legs[0]['steps'] as List?;
            if (rawSteps != null) {
              for (var s in rawSteps) {
                final instruction = s['navigationInstruction']?['instructions']?.toString() ??
                    s['headline']?.toString() ??
                    'Continue';
                final maneuver = s['navigationInstruction']?['maneuver']
                        ?.toString()
                        .toLowerCase()
                        .replaceAll('_', '-') ??
                    'straight';
                final dist = (s['distanceMeters'] as num?)?.toDouble() ?? 0;
                final startLoc = s['startLocation']?['latLng'];
                final startLat = (startLoc?['latitude'] as num?)?.toDouble() ?? 0;
                final startLng = (startLoc?['longitude'] as num?)?.toDouble() ?? 0;

                steps.add(
                  RouteStep(
                    instruction: instruction,
                    maneuver: maneuver,
                    distanceMeters: dist,
                    startLocation: LatLng(startLat, startLng),
                  ),
                );
              }
            }
          }

          debugPrint('✅ [Google Routes v2 Success]: Decoded ${decodedPoints.length} points, Distance: ${distanceMeters.toStringAsFixed(0)}m, Duration: $durationText, Steps: ${steps.length}');

          return RouteDirectionResult(
            polylinePoints: decodedPoints,
            distanceInMeters: distanceMeters,
            durationText: durationText,
            steps: steps,
            source: 'google_routes_v2',
          );
        }
      }
      debugPrint('⚠️ [Google Routes v2 Response]: No routes found in response: ${response.body}');
    } else {
      debugPrint('❌ [Google Routes v2 Error]: Status ${response.statusCode}, Body: ${response.body}');
    }
    return null;
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

    debugPrint('🌐 [Google API Request]: $url');

    final response = await http.get(url).timeout(const Duration(seconds: 8));
    debugPrint('📡 [Google API HTTP Status]: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final status = data['status']?.toString() ?? 'UNKNOWN';

      if (status == 'OK' && (data['routes'] as List).isNotEmpty) {
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

        debugPrint('✅ [Google API Success]: Decoded ${decodedPoints.length} polyline points, Distance: ${distanceMeters.toStringAsFixed(0)}m, Duration: $duration, Steps: ${steps.length}');

        return RouteDirectionResult(
          polylinePoints: decodedPoints,
          distanceInMeters: distanceMeters,
          durationText: duration,
          steps: steps,
          source: 'google',
        );
      } else {
        final errorMessage = data['error_message'] ?? 'No extra error message provided by Google';
        debugPrint('❌ [Google API Returned Error Status]: $status');
        debugPrint('❌ [Google API Error Details]: $errorMessage');
        debugPrint('   Raw response: ${response.body}');
      }
    } else {
      debugPrint('❌ [Google API HTTP Error]: Code ${response.statusCode}, Body: ${response.body}');
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

    debugPrint('🌐 [OSRM Request]: $url');

    final response = await http.get(url).timeout(const Duration(seconds: 8));
    debugPrint('📡 [OSRM HTTP Status]: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final code = data['code']?.toString() ?? '';
      if (code == 'Ok' && (data['routes'] as List).isNotEmpty) {
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

        debugPrint('✅ [OSRM Success]: Decoded ${points.length} coordinates, Distance: ${distanceMeters.toStringAsFixed(0)}m, Duration: $durationText, Steps: ${steps.length}');

        return RouteDirectionResult(
          polylinePoints: points,
          distanceInMeters: distanceMeters,
          durationText: durationText,
          steps: steps,
          source: 'osrm',
        );
      } else {
        debugPrint('❌ [OSRM Error]: Code $code, Message: ${data['message'] ?? 'None'}');
      }
    } else {
      debugPrint('❌ [OSRM HTTP Error]: Code ${response.statusCode}, Body: ${response.body}');
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
