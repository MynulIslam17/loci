import 'dart:async';
import 'dart:math' as math;
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
  final isUserPanning = false.obs; // User manually touched/zoomed/panned map during navigation
  final is3DMode = true.obs; // 2D vs 3D Perspective Toggle
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
  final circles = <Circle>{}.obs;
  GoogleMapController? mapController;

  // Vehicle & User Marker Icons
  BitmapDescriptor? _arrowIcon;
  final List<BitmapDescriptor> _pulsingDotFrames = [];
  int _currentPulseFrameIndex = 0;

  double _currentBearing = 0.0;
  double _targetBearing = 0.0;
  double? userPreferredNavZoom;
  bool _isProgrammaticCameraMove = false;
  Position? _previousPosition;
  DateTime? _lastCameraUpdate;
  bool _hasShownArrivalDialog = false;
  Timer? _animationTimer;

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
      _startAnimationLoop();
    });
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
    _pollTimer?.cancel();
    _animationTimer?.cancel();
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

  /// Pre-generates custom vehicle markers:
  /// - navigation_arrow.svg for all 3 travel modes (Drive, Ride, Walk) when navigating
  /// - 16 smooth animated pulsing blue dot frames with directional heading cone for preview before starting navigation
  Future<void> _loadCustomMarkerIcons() async {
    try {
      // 🧭 1. Load navigation_arrow.svg for all 3 travel modes
      _arrowIcon = await _loadArrowSvgMarker('assets/icons/navigation_arrow.svg');

      // 📍 2. Pre-generate 16 smooth animated pulsing blue dot frames with directional beam
      _pulsingDotFrames.clear();
      const int frameCount = 16;
      for (int i = 0; i < frameCount; i++) {
        final double progress = i / frameCount;
        final frame = await _createPulsingDotFrame(progress);
        _pulsingDotFrames.add(frame);
      }
    } catch (e) {
      _logger.w('Failed to create custom marker bitmaps: $e');
    }
  }

  /// Rasterizes navigation_arrow.svg to a high-DPI transparent PNG BitmapDescriptor
  Future<BitmapDescriptor> _loadArrowSvgMarker(String svgAssetPath) async {
    try {
      const double targetSize = 56.0;

      final pictureInfo = await vg.loadPicture(
        SvgAssetLoader(svgAssetPath),
        null,
      );

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final double scaleX = targetSize / pictureInfo.size.width;
      final double scaleY = targetSize / pictureInfo.size.height;
      canvas.scale(scaleX, scaleY);
      canvas.drawPicture(pictureInfo.picture);

      final ui.Image image = await recorder
          .endRecording()
          .toImage(targetSize.toInt(), targetSize.toInt());
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      }
    } catch (e) {
      _logger.w('Failed to rasterize arrow SVG ($svgAssetPath): $e');
    }
    return _createModeIconBitmap(
      iconData: Icons.navigation_rounded,
      accentColor: const Color(0xFFE21B1B),
    );
  }

  /// Creates a single frame of the Google Maps pulsing blue dot with directional beam
  Future<BitmapDescriptor> _createPulsingDotFrame(double t) async {
    const double size = 120.0;
    const Offset center = Offset(size / 2, size / 2);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // 1. Soft directional heading beam / cone pointing straight UP (North: -90 degrees)
    // Spans ~68 degrees angle with smooth radial gradient (matches Google Maps flashlight)
    final Path beamPath = Path();
    beamPath.moveTo(center.dx, center.dy);
    beamPath.arcTo(
      Rect.fromCircle(center: center, radius: 54.0),
      -math.pi / 2 - (math.pi * 0.19),
      math.pi * 0.38,
      false,
    );
    beamPath.close();

    final Paint beamPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        54.0,
        [
          const Color(0x802563EB), // ~50% blue at origin
          const Color(0x302563EB), // ~19% blue mid-distance
          const Color(0x002563EB), // 0% fade at outer edge
        ],
        [0.0, 0.65, 1.0],
      );
    canvas.drawPath(beamPath, beamPaint);

    // 2. Animated Pulsing Outer Halo Wave (Expands from 12px to 42px and fades out)
    final double pulseRadius = 12.0 + (t * 30.0);
    final double pulseOpacity = (1.0 - t) * 0.38;
    if (pulseOpacity > 0) {
      final Paint pulsePaint = Paint()
        ..color = const Color(0xFF2563EB).withValues(alpha: pulseOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // 3. Drop Shadow for Core Dot
    final Paint shadowPaint = Paint()
      ..color = const Color(0x3A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawCircle(center + const Offset(0, 1.5), 11.5, shadowPaint);

    // 4. Solid Crisp White Ring
    final Paint whiteRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 11.0, whiteRingPaint);

    // 5. Solid Crisp Blue Center Core Dot
    final Paint coreDotPaint = Paint()
      ..color = const Color(0xFF1D68E8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7.5, coreDotPaint);

    // 6. Specular Highlight
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center - const Offset(2.0, 2.0), 2.2, highlightPaint);

    final ui.Image image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createModeIconBitmap({
    required IconData iconData,
    required Color accentColor,
  }) async {
    const double size = 88.0;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint haloPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, haloPaint);

    final Paint shadowPaint = Paint()
      ..color = const Color(0x38000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    canvas.drawCircle(const Offset(size / 2, size / 2 + 2), size / 2.7, shadowPaint);

    final Paint whiteCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.7, whiteCirclePaint);

    final Paint ringPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.7 - 1.25, ringPaint);

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

  /// High-rate smooth animation & heading interpolation loop
  void _startAnimationLoop() {
    _animationTimer?.cancel();
    if (_pulsingDotFrames.isEmpty) return;

    _animationTimer = Timer.periodic(const Duration(milliseconds: 75), (_) {
      final pos = currentPosition.value;
      if (pos == null) return;

      // 1. Smoothly interpolate bearing towards target heading using shortest circular angular distance
      final double diff = (_targetBearing - _currentBearing + 540.0) % 360.0 - 180.0;
      bool hasRotated = false;
      if (diff.abs() > 0.4) {
        _currentBearing = (_currentBearing + diff * 0.25 + 360.0) % 360.0;
        hasRotated = true;
      } else if (diff.abs() > 0.05) {
        _currentBearing = _targetBearing;
        hasRotated = true;
      }

      // 2. Advance pulse frame if in preview mode (before starting navigation)
      bool frameChanged = false;
      if (!isNavigating.value && _pulsingDotFrames.isNotEmpty) {
        _currentPulseFrameIndex =
            (_currentPulseFrameIndex + 1) % _pulsingDotFrames.length;
        frameChanged = true;
      }

      if (hasRotated || frameChanged) {
        _updateUserMarker(pos);

        if (isNavigating.value && hasRotated && !isUserPanning.value && !_isProgrammaticCameraMove) {
          final now = DateTime.now();
          if (_lastCameraUpdate == null ||
              now.difference(_lastCameraUpdate!).inMilliseconds > 120) {
            _lastCameraUpdate = now;
            _followUserInNavigationMode(pos);
          }
        }
      }
    });
  }

  /// Called when camera moves started (differentiates between user and programmatic)
  void onCameraMoveStarted() {
    if (!_isProgrammaticCameraMove && isNavigating.value) {
      isUserPanning.value = true;
    }
  }

  /// Called continuously as camera position/zoom changes
  void onCameraMove(CameraPosition position) {
    if (!_isProgrammaticCameraMove && isNavigating.value && isUserPanning.value) {
      userPreferredNavZoom = position.zoom;
    }
  }

  BitmapDescriptor _getActiveMarkerIcon() {
    if (isNavigating.value) {
      // 🚀 All 3 travel modes (Drive, Ride, Walk) use the new navigation_arrow.svg marker
      return _arrowIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    // Before starting navigation: Use animated pulsing dot with directional heading cone
    if (_pulsingDotFrames.isNotEmpty) {
      return _pulsingDotFrames[_currentPulseFrameIndex];
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
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
      if (heading != null) {
        _targetBearing = (heading + 360.0) % 360.0;
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

      if (movedMeters >= 0.8) {
        final calcBearing = Geolocator.bearingBetween(
          _previousPosition!.latitude,
          _previousPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );
        if (calcBearing != 0.0) {
          _targetBearing = (calcBearing + 360.0) % 360.0;
        } else if (newPosition.heading > 0) {
          _targetBearing = newPosition.heading;
        }
      }
    }

    _previousPosition = newPosition;
    currentPosition.value = newPosition;
    _updateUserMarker(newPosition);

    _trimPolylineFromUserPosition(newPosition);
    _updateNextTurnInstruction(newPosition);
    _checkOffRouteAndRecalculate(newPosition);

    if (isNavigating.value && !isUserPanning.value) {
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
      rotation: _currentBearing,
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
      if (isNavigating.value) {
        _followUserInNavigationMode(pos);
      } else {
        fitCameraToBounds();
      }
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

        final casingPolyline = Polyline(
          polylineId: const PolylineId('route_polyline_casing'),
          points: _fullRoutePoints,
          color: const Color(0xFF1548A6),
          width: 9,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          zIndex: 4,
        );

        final mainPolyline = Polyline(
          polylineId: const PolylineId('route_polyline'),
          points: _fullRoutePoints,
          color: const Color(0xFF1D68E8),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          zIndex: 5,
        );

        polylines.assignAll({casingPolyline, mainPolyline});

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

  /// Orthogonal projection to snap coordinate onto road segment
  LatLng _projectPointOnSegment(LatLng p, LatLng a, LatLng b) {
    final dx = b.longitude - a.longitude;
    final dy = b.latitude - a.latitude;
    if (dx == 0 && dy == 0) return a;

    final t = ((p.longitude - a.longitude) * dx + (p.latitude - a.latitude) * dy) /
        (dx * dx + dy * dy);
    final clampedT = t.clamp(0.0, 1.0);

    return LatLng(
      a.latitude + clampedT * dy,
      a.longitude + clampedT * dx,
    );
  }

  void _trimPolylineFromUserPosition(Position userPos) {
    if (_fullRoutePoints.isEmpty) return;

    final userLatLng = LatLng(userPos.latitude, userPos.longitude);

    int closestSegmentIndex = 0;
    double minDistance = double.infinity;
    LatLng closestSnappedPoint = _fullRoutePoints.first;

    for (int i = 0; i < _fullRoutePoints.length - 1; i++) {
      final a = _fullRoutePoints[i];
      final b = _fullRoutePoints[i + 1];
      final snapped = _projectPointOnSegment(userLatLng, a, b);
      final d = LocationService.instance.distanceBetween(
        startLatitude: userLatLng.latitude,
        startLongitude: userLatLng.longitude,
        endLatitude: snapped.latitude,
        endLongitude: snapped.longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        closestSegmentIndex = i;
        closestSnappedPoint = snapped;
      }
    }

    List<LatLng> remainingRoute;
    if (minDistance > 35.0) {
      // User is far off the road
      remainingRoute = [
        userLatLng,
        ..._fullRoutePoints.sublist(closestSegmentIndex + 1),
      ];
    } else {
      // Snapped to street segment (prevents line cutting across 3D buildings)
      remainingRoute = [
        closestSnappedPoint,
        ..._fullRoutePoints.sublist(closestSegmentIndex + 1),
      ];
    }

    if (remainingRoute.length < 2) {
      remainingRoute = [userLatLng, _fullRoutePoints.last];
    }

    final casingPolyline = Polyline(
      polylineId: const PolylineId('route_polyline_casing'),
      points: remainingRoute,
      color: const Color(0xFF1548A6),
      width: 9,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 4,
    );

    final updatedPolyline = Polyline(
      polylineId: const PolylineId('route_polyline'),
      points: remainingRoute,
      color: const Color(0xFF1D68E8),
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 5,
    );
    polylines.assignAll({casingPolyline, updatedPolyline});

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

  /// Starts In-App Live Navigation Mode (smooth 3D swoop zoom-in)
  void startInAppNavigation() {
    isNavigating.value = true;
    isUserPanning.value = false;
    userPreferredNavZoom = null;
    _hasShownArrivalDialog = false;
    final pos = currentPosition.value;
    if (pos != null) {
      _updateUserMarker(pos);
      _followUserInNavigationMode(pos);
    }
  }

  /// Exits In-App Navigation Mode back to 2D overview (smooth zoom-out)
  void stopInAppNavigation() {
    isNavigating.value = false;
    isUserPanning.value = false;
    userPreferredNavZoom = null;
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

  /// Called when user touches or drags the map
  void onUserTouchMap() {
    if (isNavigating.value && !_isProgrammaticCameraMove) {
      isUserPanning.value = true;
    }
  }

  /// Sets Perspective Mode to 2D (tilt 0°) or 3D (tilt 58°)
  void setPerspectiveMode(bool is3d) {
    is3DMode.value = is3d;
    final targetTilt = is3d ? 58.0 : 0.0;

    if (mapController == null) return;
    final pos = currentPosition.value;
    final targetLat = pos?.latitude ?? (destLat != 0.0 ? destLat : 23.7808);
    final targetLng = pos?.longitude ?? (destLng != 0.0 ? destLng : 90.4075);
    final defaultZoom = selectedTravelMode.value == 'walking' ? 19.2 : 18.2;
    final targetZoom = userPreferredNavZoom ?? (isNavigating.value ? defaultZoom : 16.5);
    final targetBearing = is3d ? _currentBearing : 0.0;

    _isProgrammaticCameraMove = true;
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(targetLat, targetLng),
          zoom: targetZoom,
          tilt: targetTilt,
          bearing: targetBearing,
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      _isProgrammaticCameraMove = false;
    });
  }

  /// Toggles between 2D Top-Down and 3D Tilted Perspective
  void toggle2D3DMode() {
    setPerspectiveMode(!is3DMode.value);
  }

  /// Smoothly tracks the user in 3D/2D HUD perspective (Google Maps navigation camera)
  void _followUserInNavigationMode(Position pos) {
    if (mapController == null) return;

    final defaultZoom = selectedTravelMode.value == 'walking' ? 19.2 : 18.2;
    final targetZoom = userPreferredNavZoom ?? defaultZoom;
    final targetTilt = is3DMode.value ? 58.0 : 0.0;

    _isProgrammaticCameraMove = true;
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: targetZoom,
          tilt: targetTilt,
          bearing: _currentBearing,
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      _isProgrammaticCameraMove = false;
    });
  }

  /// Smoothly fits origin, route, and destination into 2D overview
  void fitCameraToBounds() {
    if (mapController == null) return;

    final pos = currentPosition.value;
    if (pos == null || (destLat == 0.0 && destLng == 0.0)) {
      if (destLat != 0.0 && destLng != 0.0) {
        _isProgrammaticCameraMove = true;
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(destLat, destLng),
              zoom: 15.5,
              tilt: 0.0,
              bearing: 0.0,
            ),
          ),
        );
        Future.delayed(const Duration(milliseconds: 400), () {
          _isProgrammaticCameraMove = false;
        });
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
      _isProgrammaticCameraMove = true;
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 15.5,
            tilt: 0.0,
            bearing: 0.0,
          ),
        ),
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        _isProgrammaticCameraMove = false;
      });
      return;
    }

    // Calculate bounding box containing all points on the route (or origin + destination)
    double minLat = math.min(pos.latitude, destLat);
    double maxLat = math.max(pos.latitude, destLat);
    double minLng = math.min(pos.longitude, destLng);
    double maxLng = math.max(pos.longitude, destLng);

    if (_fullRoutePoints.isNotEmpty) {
      for (final pt in _fullRoutePoints) {
        if (pt.latitude < minLat) minLat = pt.latitude;
        if (pt.latitude > maxLat) maxLat = pt.latitude;
        if (pt.longitude < minLng) minLng = pt.longitude;
        if (pt.longitude > maxLng) maxLng = pt.longitude;
      }
    }

    // If points are very close (e.g. less than 100m)
    if ((maxLat - minLat).abs() < 0.001 && (maxLng - minLng).abs() < 0.001) {
      _isProgrammaticCameraMove = true;
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
            zoom: 16.5,
            tilt: 0.0,
            bearing: 0.0,
          ),
        ),
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        _isProgrammaticCameraMove = false;
      });
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _isProgrammaticCameraMove = true;
    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 65),
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      _isProgrammaticCameraMove = false;
    });
  }

  void recenterOnUser() {
    isUserPanning.value = false;
    final pos = currentPosition.value;
    if (pos != null && mapController != null) {
      if (isNavigating.value) {
        _followUserInNavigationMode(pos);
      } else {
        _isProgrammaticCameraMove = true;
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(pos.latitude, pos.longitude),
              zoom: 16.5,
              tilt: 0.0,
              bearing: 0.0,
            ),
          ),
        );
        Future.delayed(const Duration(milliseconds: 400), () {
          _isProgrammaticCameraMove = false;
        });
      }
    }
  }
}
