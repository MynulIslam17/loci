import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loci/core/services/location/location_service.dart';
import 'package:loci/core/services/location/route_direction_service.dart';
import 'package:loci/features/navigation/presentation/widgets/live_navigation_arrival_dialog.dart';
import 'package:logger/logger.dart';

class LiveNavigationController extends GetxController {
  final Logger _logger = Logger();

  // Destination Arguments
  late final double destLat;
  late final double destLng;
  late final String destinationTitle;
  late final String? locationLabel;

  // Reactive Navigation State
  final isLoading = true.obs;
  final isRouteLoading = false.obs;
  final isNavigating = false.obs; // Active In-App Navigation HUD Mode
  final selectedTravelMode = 'driving'.obs; // 'driving', 'twoWheeler', 'walking'
  final currentPosition = Rxn<Position>();
  final remainingDistance = ''.obs;
  final estimatedDuration = ''.obs;
  final isUserNearDestination = false.obs;

  // Turn-by-Turn Dynamic Maneuvers
  final currentInstruction = ''.obs;
  final currentManeuver = 'straight'.obs;
  final distanceToNextTurn = ''.obs;

  // Google Map State
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  GoogleMapController? mapController;

  // Vehicle Marker Icons
  BitmapDescriptor? _driveIcon;
  BitmapDescriptor? _rideIcon;
  BitmapDescriptor? _walkIcon;
  BitmapDescriptor? _userDotIcon;

  double _currentBearing = 0.0;
  Position? _previousPosition;
  DateTime? _lastCameraUpdate;
  bool _hasShownArrivalDialog = false;

  // Route points & turn steps
  List<LatLng> _fullRoutePoints = [];
  List<RouteStep> _routeSteps = [];

  // Dual Streams: 1. Continuous Location Stream, 2. Hardware Magnetometer Compass Stream
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _pollTimer;
  double _lastDistanceMeters = 0;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    _loadCustomMarkerIcons().then((_) {
      _initializeLocationAndRoute();
      _startHardwareCompassStream();
    });
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
    _pollTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      destLat = (args['latitude'] as num?)?.toDouble() ?? 0.0;
      destLng = (args['longitude'] as num?)?.toDouble() ?? 0.0;
      destinationTitle = args['title'] as String? ?? 'Destination';
      locationLabel = args['locationLabel'] as String?;
    } else {
      destLat = 0.0;
      destLng = 0.0;
      destinationTitle = 'Destination';
      locationLabel = null;
    }
  }

  /// Pre-generates custom vehicle markers: Existing car SVG for Drive and Ride, Arrow for Walk
  Future<void> _loadCustomMarkerIcons() async {
    try {
      // 🚗 Use the existing car SVG (assets/icons/nav_car1.svg) for BOTH Drive and Ride modes
      final carSvgMarker = await _loadCarSvgMarker('assets/icons/nav_car1.svg');
      _driveIcon = carSvgMarker;
      _rideIcon = carSvgMarker;

      // 🚶 Walk mode: Default navigation direction pointer
      _walkIcon = await _createModeIconBitmap(
        iconData: Icons.navigation_rounded,
        accentColor: const Color(0xFFF59E0B),
      );

      _userDotIcon = await _createDotBitmap();
    } catch (e) {
      _logger.w('Failed to create custom marker bitmaps: $e');
    }
  }

  /// Rasterizes the existing nav_car1.svg to a high-DPI transparent PNG BitmapDescriptor for Google Maps
  Future<BitmapDescriptor> _loadCarSvgMarker(String svgAssetPath) async {
    try {
      // Sleek, compact standard vehicle proportion for all mobile displays (1 : 2.09 aspect ratio)
      const double targetWidth = 38.0;
      const double targetHeight = 79.0;

      final pictureInfo = await vg.loadPicture(
        SvgAssetLoader(svgAssetPath),
        null,
      );

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Scale picture cleanly to target dimensions
      final double scaleX = targetWidth / pictureInfo.size.width;
      final double scaleY = targetHeight / pictureInfo.size.height;
      canvas.scale(scaleX, scaleY);
      canvas.drawPicture(pictureInfo.picture);

      final ui.Image image = await recorder
          .endRecording()
          .toImage(targetWidth.toInt(), targetHeight.toInt());
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      }
    } catch (e) {
      _logger.w('Failed to rasterize existing car SVG ($svgAssetPath): $e');
    }
    return _createModeIconBitmap(
      iconData: Icons.directions_car_rounded,
      accentColor: const Color(0xFF2563EB),
    );
  }

  Future<BitmapDescriptor> _createModeIconBitmap({
    required IconData iconData,
    required Color accentColor,
  }) async {
    const double size = 88.0;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // 1. Soft Outer Halo
    final Paint haloPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, haloPaint);

    // 2. White Base with Drop Shadow
    final Paint shadowPaint = Paint()
      ..color = const Color(0x38000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    canvas.drawCircle(const Offset(size / 2, size / 2 + 2), size / 2.7, shadowPaint);

    final Paint whiteCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.7, whiteCirclePaint);

    // 3. Colored Accent Border
    final Paint ringPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.7 - 1.25, ringPaint);

    // 4. Vector Icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 34.0,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: accentColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createDotBitmap() async {
    const double size = 60.0;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint haloPaint = Paint()
      ..color = const Color(0x352563EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, haloPaint);

    final Paint whiteRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 3, whiteRingPaint);

    final Paint coreDotPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 4.2, coreDotPaint);

    final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  BitmapDescriptor _getActiveMarkerIcon() {
    if (!isNavigating.value) {
      return _userDotIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    final mode = selectedTravelMode.value;
    if (mode == 'walking') {
      return _walkIcon ?? _userDotIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    } else {
      // Both 'driving' and 'twoWheeler' (Ride) use the existing car SVG marker
      return _driveIcon ?? _rideIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  Future<void> _initializeLocationAndRoute() async {
    try {
      _updateDestinationMarker();

      final position = await LocationService.instance.getCurrentPosition();
      if (position != null) {
        currentPosition.value = position;
        _previousPosition = position;
        _updateUserMarker(position);
        await _fetchAndDrawRoute(position);
      } else {
        _logger.w('Could not retrieve initial user position.');
      }

      _startLiveTracking();
    } catch (e, stack) {
      _logger.e('Failed to initialize live navigation', error: e, stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🧭 STREAM 1: Hardware Compass Stream (rotates marker when rotating phone in hand)
  void _startHardwareCompassStream() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) return;

      _currentBearing = (heading + 360.0) % 360.0;

      final pos = currentPosition.value;
      if (pos != null) {
        _updateUserMarker(pos);

        if (isNavigating.value) {
          final now = DateTime.now();
          if (_lastCameraUpdate == null || now.difference(_lastCameraUpdate!).inMilliseconds > 120) {
            _lastCameraUpdate = now;
            _followUserInNavigationMode(pos);
          }
        }
      }
    });
  }

  /// 🛰️ STREAM 2: Continuous High-Frequency Location Stream
  void _startLiveTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.instance
        .getPositionStream(distanceFilterInMeters: 0)
        .listen(
      _processNewPosition,
      onError: (err) {
        _logger.w('Position stream error: $err');
      },
    );

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            timeLimit: Duration(seconds: 2),
          ),
        );
        _processNewPosition(pos);
      } catch (_) {}
    });
  }

  void _processNewPosition(Position newPosition) {
    if (_previousPosition != null) {
      final movedMeters = LocationService.instance.distanceBetween(
        startLatitude: _previousPosition!.latitude,
        startLongitude: _previousPosition!.longitude,
        endLatitude: newPosition.latitude,
        endLongitude: newPosition.longitude,
      );

      if (movedMeters >= 1.5 && newPosition.heading > 0) {
        _currentBearing = newPosition.heading;
      }
    }

    _previousPosition = newPosition;
    currentPosition.value = newPosition;
    _updateUserMarker(newPosition);

    _trimPolylineFromUserPosition(newPosition);
    _updateNextTurnInstruction(newPosition);
    _checkOffRouteAndRecalculate(newPosition);

    if (isNavigating.value) {
      _followUserInNavigationMode(newPosition);
    }
  }

  void _updateUserMarker(Position pos) {
    final icon = _getActiveMarkerIcon();

    final userMarker = Marker(
      markerId: const MarkerId('user_current_location'),
      position: LatLng(pos.latitude, pos.longitude),
      icon: icon,
      infoWindow: const InfoWindow(title: 'You are here'),
      anchor: const Offset(0.5, 0.5),
      flat: true,
      rotation: isNavigating.value ? _currentBearing : 0.0,
      zIndexInt: 10,
    );

    final updated = Set<Marker>.from(markers.where((m) => m.markerId.value != 'user_current_location'));
    updated.add(userMarker);
    markers.assignAll(updated);
  }

  void _updateDestinationMarker() {
    if (destLat == 0.0 && destLng == 0.0) return;

    final destMarker = Marker(
      markerId: const MarkerId('event_destination'),
      position: LatLng(destLat, destLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: destinationTitle,
        snippet: locationLabel ?? 'Destination',
      ),
      zIndexInt: 5,
    );

    final updated = Set<Marker>.from(markers.where((m) => m.markerId.value != 'event_destination'));
    updated.add(destMarker);
    markers.assignAll(updated);
  }

  /// Change travel mode (Drive 🚗, Ride 🏍️, Walk 🚶)
  Future<void> changeTravelMode(String mode) async {
    if (selectedTravelMode.value == mode) return;
    selectedTravelMode.value = mode;

    final pos = currentPosition.value;
    if (pos != null) {
      _updateUserMarker(pos);
      await _fetchAndDrawRoute(pos);
    }
  }

  Future<void> _fetchAndDrawRoute(Position userPos) async {
    if (destLat == 0.0 && destLng == 0.0) return;

    isRouteLoading.value = true;
    try {
      final directionMode = selectedTravelMode.value == 'walking'
          ? 'walking'
          : (selectedTravelMode.value == 'twoWheeler' ? 'bicycling' : 'driving');

      final result = await RouteDirectionService.instance.getDirections(
        originLat: userPos.latitude,
        originLng: userPos.longitude,
        destLat: destLat,
        destLng: destLng,
        mode: directionMode,
      );

      if (result.polylinePoints.isNotEmpty) {
        _fullRoutePoints = List<LatLng>.from(result.polylinePoints);
        _routeSteps = List<RouteStep>.from(result.steps);

        final polyline = Polyline(
          polylineId: const PolylineId('route_polyline'),
          points: _fullRoutePoints,
          color: const Color(0xFF2563EB),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        );

        polylines.assignAll({polyline});

        if (_routeSteps.isNotEmpty) {
          currentInstruction.value = _routeSteps[0].instruction;
          currentManeuver.value = _routeSteps[0].maneuver;
          distanceToNextTurn.value = LocationService.formatDistance(_routeSteps[0].distanceMeters);
        } else {
          currentInstruction.value = 'Head towards $destinationTitle';
          currentManeuver.value = 'straight';
          distanceToNextTurn.value = LocationService.formatDistance(result.distanceInMeters);
        }
      }

      _lastDistanceMeters = result.distanceInMeters > 0
          ? result.distanceInMeters
          : LocationService.instance.distanceBetween(
              startLatitude: userPos.latitude,
              startLongitude: userPos.longitude,
              endLatitude: destLat,
              endLongitude: destLng,
            );

      remainingDistance.value = LocationService.formatDistance(_lastDistanceMeters);
      estimatedDuration.value = result.durationText ??
          _formatModeEta(_lastDistanceMeters, selectedTravelMode.value);

      if (!isNavigating.value) {
        fitCameraToBounds();
      }
    } catch (e) {
      _logger.w('Error fetching route: $e');
    } finally {
      isRouteLoading.value = false;
    }
  }

  void _trimPolylineFromUserPosition(Position userPos) {
    if (_fullRoutePoints.isEmpty || (destLat == 0.0 && destLng == 0.0)) return;

    final userLatLng = LatLng(userPos.latitude, userPos.longitude);

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < _fullRoutePoints.length; i++) {
      final d = LocationService.instance.distanceBetween(
        startLatitude: userPos.latitude,
        startLongitude: userPos.longitude,
        endLatitude: _fullRoutePoints[i].latitude,
        endLongitude: _fullRoutePoints[i].longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }

    List<LatLng> remainingRoute;
    if (closestIndex >= _fullRoutePoints.length - 1) {
      remainingRoute = [userLatLng, LatLng(destLat, destLng)];
    } else {
      remainingRoute = [
        userLatLng,
        ..._fullRoutePoints.sublist(closestIndex + 1),
      ];
    }

    final updatedPolyline = Polyline(
      polylineId: const PolylineId('route_polyline'),
      points: remainingRoute,
      color: const Color(0xFF2563EB),
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
    polylines.assignAll({updatedPolyline});

    double roadDistanceMeters = 0;
    for (int i = 0; i < remainingRoute.length - 1; i++) {
      roadDistanceMeters += LocationService.instance.distanceBetween(
        startLatitude: remainingRoute[i].latitude,
        startLongitude: remainingRoute[i].longitude,
        endLatitude: remainingRoute[i + 1].latitude,
        endLongitude: remainingRoute[i + 1].longitude,
      );
    }

    if (roadDistanceMeters == 0) {
      roadDistanceMeters = LocationService.instance.distanceBetween(
        startLatitude: userPos.latitude,
        startLongitude: userPos.longitude,
        endLatitude: destLat,
        endLongitude: destLng,
      );
    }

    _lastDistanceMeters = roadDistanceMeters;
    remainingDistance.value = LocationService.formatDistance(roadDistanceMeters);
    estimatedDuration.value = _formatModeEta(roadDistanceMeters, selectedTravelMode.value);

    // 🏁 Arrival Detection: <= 15 meters
    if (roadDistanceMeters <= 15) {
      isUserNearDestination.value = true;
      currentInstruction.value = 'You have arrived at $destinationTitle!';
      currentManeuver.value = 'flag';

      if (!_hasShownArrivalDialog) {
        _hasShownArrivalDialog = true;
        _showArrivalDialog();
      }
    }
  }

  void _updateNextTurnInstruction(Position userPos) {
    if (_routeSteps.isEmpty || isUserNearDestination.value) return;

    for (final step in _routeSteps) {
      final distToStep = LocationService.instance.distanceBetween(
        startLatitude: userPos.latitude,
        startLongitude: userPos.longitude,
        endLatitude: step.startLocation.latitude,
        endLongitude: step.startLocation.longitude,
      );

      if (distToStep > 12) {
        currentInstruction.value = step.instruction;
        currentManeuver.value = step.maneuver;
        distanceToNextTurn.value = LocationService.formatDistance(distToStep);
        return;
      }
    }

    currentInstruction.value = 'In 50m, destination is ahead';
    currentManeuver.value = 'straight';
    distanceToNextTurn.value = remainingDistance.value;
  }

  void _checkOffRouteAndRecalculate(Position userPos) {
    if (_fullRoutePoints.isEmpty || isRouteLoading.value) return;

    double minDistanceToRoute = double.infinity;
    for (final pt in _fullRoutePoints) {
      final d = LocationService.instance.distanceBetween(
        startLatitude: userPos.latitude,
        startLongitude: userPos.longitude,
        endLatitude: pt.latitude,
        endLongitude: pt.longitude,
      );
      if (d < minDistanceToRoute) {
        minDistanceToRoute = d;
      }
    }

    if (minDistanceToRoute > 35.0) {
      _logger.i('User off route ($minDistanceToRoute m). Recalculating...');
      _fetchAndDrawRoute(userPos);
    }
  }

  String _formatModeEta(double distanceMeters, String mode) {
    double metersPerMin = 500;
    if (mode == 'walking') {
      metersPerMin = 83;
    } else if (mode == 'twoWheeler') {
      metersPerMin = 580;
    }

    final mins = (distanceMeters / metersPerMin).round();
    if (mins <= 1) return '1 min';
    if (mins < 60) return '$mins min';
    final hr = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '$hr hr' : '$hr hr $m min';
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    fitCameraToBounds();
  }

  /// Starts In-App Live Navigation Mode
  void startInAppNavigation() {
    isNavigating.value = true;
    _hasShownArrivalDialog = false;
    final pos = currentPosition.value;
    if (pos != null) {
      _updateUserMarker(pos);
      _followUserInNavigationMode(pos);
    }
  }

  /// Exits In-App Navigation Mode back to 2D overview
  void stopInAppNavigation() {
    isNavigating.value = false;
    final pos = currentPosition.value;
    if (pos != null) {
      _updateUserMarker(pos);
    }
    fitCameraToBounds();
  }

  void _showArrivalDialog() {
    stopInAppNavigation();
    LiveNavigationArrivalDialog.show(
      title: destinationTitle,
      locationLabel: locationLabel,
      onDone: fitCameraToBounds,
    );
  }

  void _followUserInNavigationMode(Position pos) {
    if (mapController == null) return;

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 18.5,
          tilt: 58.0,
          bearing: _currentBearing,
        ),
      ),
    );
  }

  void fitCameraToBounds() {
    if (mapController == null) return;

    final pos = currentPosition.value;
    if (pos == null || (destLat == 0.0 && destLng == 0.0)) {
      if (destLat != 0.0 && destLng != 0.0) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(destLat, destLng), 15.5),
        );
      }
      return;
    }

    final distanceMeters = LocationService.instance.distanceBetween(
      startLatitude: pos.latitude,
      startLongitude: pos.longitude,
      endLatitude: destLat,
      endLongitude: destLng,
    );

    if (distanceMeters > 500000) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(destLat, destLng), 15.5),
      );
      return;
    }

    final southwestLat = pos.latitude < destLat ? pos.latitude : destLat;
    final southwestLng = pos.longitude < destLng ? pos.longitude : destLng;
    final northeastLat = pos.latitude > destLat ? pos.latitude : destLat;
    final northeastLng = pos.longitude > destLng ? pos.longitude : destLng;

    final bounds = LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void recenterOnUser() {
    final pos = currentPosition.value;
    if (pos != null && mapController != null) {
      if (isNavigating.value) {
        _followUserInNavigationMode(pos);
      } else {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16.5),
        );
      }
    }
  }
}
