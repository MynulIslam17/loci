import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteStep {
  const RouteStep({
    required this.instruction,
    required this.maneuver,
    required this.distanceMeters,
    required this.startLocation,
  });

  final String instruction;
  final String maneuver;
  final double distanceMeters;
  final LatLng startLocation;
}
