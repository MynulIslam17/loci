import 'dart:async';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

/// Service responsible for GPS permission handling, position streaming, and distance calculation.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();
  final Logger _logger = Logger();

  /// Checks and requests location permission.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> checkAndRequestPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services are disabled on the device.');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('Location permission denied by user.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w(
          'Location permissions are permanently denied, cannot request permissions.',
        );
        return false;
      }

      return true;
    } catch (e, stack) {
      _logger.e('Error checking location permission', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Fetches the user's current GPS position with high accuracy.
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      _logger.w('Failed to get high accuracy position, falling back to last known position: $e');
      return await Geolocator.getLastKnownPosition();
    }
  }

  /// Subscribes to real-time user position changes as they move (Continuous high-frequency navigation stream).
  Stream<Position> getPositionStream({int distanceFilterInMeters = 0}) {
    late LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilterInMeters,
        forceLocationManager: false,
        // High-frequency updates so the nav arrow tracks like a ride-share app
        intervalDuration: const Duration(milliseconds: 800),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: distanceFilterInMeters,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilterInMeters,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculates distance in meters between two coordinates.
  double distanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Formats distance in meters into human-readable string (e.g. "450 m" or "3.2 km").
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Estimates travel duration (driving avg 30 km/h in city traffic) from meters.
  static String formatEstimatedDuration(double distanceInMeters) {
    // Approx city speed: 25-30 km/h -> ~450 meters per minute
    final minutes = (distanceInMeters / 450).round();
    if (minutes <= 1) {
      return '1 min';
    } else if (minutes < 60) {
      return '$minutes mins';
    } else {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      if (remainingMins == 0) {
        return '$hours hr';
      }
      return '$hours hr $remainingMins min';
    }
  }
}
