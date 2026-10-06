import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'navigation_step_model.dart';

class RouteDirectionResult {
  const RouteDirectionResult({
    required this.polylinePoints,
    required this.distanceInMeters,
    required this.steps,
    required this.source,
    this.durationText,
    this.durationSeconds,
  });

  final List<LatLng> polylinePoints;
  final double distanceInMeters;
  final String? durationText;
  final double? durationSeconds;
  final List<RouteStep> steps;
  final String source;
}
