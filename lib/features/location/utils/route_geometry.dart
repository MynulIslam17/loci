import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMatch {
  const RouteMatch({
    required this.segmentIndex,
    required this.point,
    required this.distanceMeters,
    required this.distanceAlongMeters,
    required this.routeLengthMeters,
  });

  final int segmentIndex;
  final LatLng point;
  final double distanceMeters;
  final double distanceAlongMeters;
  final double routeLengthMeters;
}

/// Matches GPS to the closest *segment*, including long segments with no
/// intermediate polyline vertices. Coordinates use a local meter projection.
RouteMatch? closestPointOnRoute(LatLng point, List<LatLng> route) {
  if (route.length < 2) return null;
  final metersPerDegreeLat = 111320.0;
  final metersPerDegreeLng =
      111320.0 *
      math.cos(point.latitude * math.pi / 180).abs().clamp(0.01, 1.0);
  var bestDistance = double.infinity;
  var bestIndex = 0;
  var bestPoint = route.first;
  var bestProgress = 0.0;
  var traversed = 0.0;

  for (var i = 0; i < route.length - 1; i++) {
    final a = route[i];
    final b = route[i + 1];
    final ax = (a.longitude - point.longitude) * metersPerDegreeLng;
    final ay = (a.latitude - point.latitude) * metersPerDegreeLat;
    final bx = (b.longitude - point.longitude) * metersPerDegreeLng;
    final by = (b.latitude - point.latitude) * metersPerDegreeLat;
    final dx = bx - ax;
    final dy = by - ay;
    final lengthSquared = dx * dx + dy * dy;
    final segmentLength = math.sqrt(lengthSquared);
    final t = lengthSquared == 0
        ? 0.0
        : ((-ax * dx - ay * dy) / lengthSquared).clamp(0.0, 1.0);
    final x = ax + t * dx;
    final y = ay + t * dy;
    final distance = math.sqrt(x * x + y * y);
    if (distance < bestDistance) {
      bestDistance = distance;
      bestIndex = i;
      bestPoint = LatLng(
        a.latitude + t * (b.latitude - a.latitude),
        a.longitude + t * (b.longitude - a.longitude),
      );
      bestProgress = traversed + segmentLength * t;
    }
    traversed += segmentLength;
  }
  return RouteMatch(
    segmentIndex: bestIndex,
    point: bestPoint,
    distanceMeters: bestDistance,
    distanceAlongMeters: bestProgress,
    routeLengthMeters: traversed,
  );
}
