import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loci/core/config/app_secrets.dart';
import 'package:loci/features/location/data/services/location_service.dart';
import 'package:loci/features/location/data/services/navigation_directions_service.dart';
import 'package:loci/features/location/presentation/widgets/navigation_map_markers.dart';
import 'package:loci/features/location/utils/route_geometry.dart';

/// Navigation state for one destination. It is disposed when the page closes.
class LiveNavigationController extends GetxController {
  final isLoading = true.obs;
  final isRouteLoading = false.obs;
  final isNavigating = false.obs;
  final isFollowing = false.obs;
  final isRerouting = false.obs;
  final selectedTravelMode = 'walking'.obs;
  final currentPosition = Rxn<Position>();
  final routeError = RxnString();
  final locationError = RxnString();
  final remainingDistance = '--'.obs;
  final estimatedDuration = '--'.obs;
  final currentInstruction = 'Follow the route'.obs;
  final distanceToNextTurn = ''.obs;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  late final double destLat;
  late final double destLng;
  late final String destinationTitle;
  late final String? locationLabel;
  GoogleMapController? _map;
  StreamSubscription<Position>? _positionSubscription;
  BitmapDescriptor? _walkingMarker;
  BitmapDescriptor? _ridingMarker;
  BitmapDescriptor? _destinationMarker;
  List<LatLng> _routePoints = const [];
  List<RouteStep> _steps = const [];
  double _routeDistance = 0;
  double _routeDurationSeconds = 0;
  int _requestId = 0;
  int _offRouteSamples = 0;
  DateTime? _lastReroute;
  bool _closed = false;
  bool _arrived = false;

  bool get isMapConfigured => AppSecrets.hasGoogleMapsApiKey;
  bool get canStart =>
      !isLoading.value &&
      !isRouteLoading.value &&
      currentPosition.value != null &&
      _routePoints.length >= 2 &&
      routeError.value == null &&
      locationError.value == null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      destLat = (args['latitude'] as num?)?.toDouble() ?? 0;
      destLng = (args['longitude'] as num?)?.toDouble() ?? 0;
      final title = args['title'] as String?;
      destinationTitle = title?.trim().isNotEmpty == true
          ? title!.trim()
          : 'Destination';
      locationLabel = args['locationLabel'] as String?;
    } else {
      destLat = 0;
      destLng = 0;
      destinationTitle = 'Destination';
      locationLabel = null;
    }
    if (_validDestination) _updateDestinationMarker();
    _loadMarkerIcons();
    initialize();
  }

  Future<void> _loadMarkerIcons() async {
    try {
      final icons = await Future.wait([
        NavigationMapMarkers.walking(),
        NavigationMapMarkers.riding(),
        NavigationMapMarkers.destination(),
      ]);
      if (_closed) return;
      _walkingMarker = icons[0];
      _ridingMarker = icons[1];
      _destinationMarker = icons[2];
      if (_validDestination) _updateDestinationMarker();
      final position = currentPosition.value;
      if (position != null) _acceptPosition(position);
    } catch (_) {
      // Default SDK markers remain usable if icon rendering is unavailable.
    }
  }

  void _updateDestinationMarker() {
    final updated = Set<Marker>.from(
      markers.where((m) => m.markerId.value != 'destination'),
    );
    updated.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(destLat, destLng),
        icon: _destinationMarker ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(title: destinationTitle),
      ),
    );
    markers.assignAll(updated);
  }

  bool get _validDestination =>
      destLat.isFinite &&
      destLng.isFinite &&
      destLat.abs() <= 90 &&
      destLng.abs() <= 180 &&
      (destLat != 0 || destLng != 0);

  Future<void> initialize() async {
    if (_closed) return;
    isLoading.value = true;
    locationError.value = null;
    if (!_validDestination || !isMapConfigured) {
      routeError.value = !_validDestination
          ? 'This destination has no valid map location.'
          : 'Google Maps is not configured in this build.';
      isLoading.value = false;
      return;
    }
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (_closed) return;
      if (position == null || !_usable(position)) {
        locationError.value =
            'Location is unavailable. Check access and retry.';
        return;
      }
      _acceptPosition(position);
      _startTracking();
      await _loadRoute(position);
    } catch (_) {
      if (!_closed) locationError.value = 'Could not get your location. Retry.';
    } finally {
      if (!_closed) isLoading.value = false;
    }
  }

  bool _usable(Position p) =>
      p.latitude.isFinite &&
      p.longitude.isFinite &&
      p.accuracy.isFinite &&
      p.accuracy <= 100 &&
      DateTime.now().difference(p.timestamp).inMinutes < 2;

  void _startTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.instance
        .getPositionStream(
          distanceFilterInMeters: selectedTravelMode.value == 'walking' ? 2 : 5,
          travelMode: selectedTravelMode.value,
        )
        .listen(
          _onPosition,
          onError: (_) {
            if (!_closed) {
              locationError.value = 'Location tracking stopped. Retry.';
            }
          },
        );
  }

  void _acceptPosition(Position position) {
    currentPosition.value = position;
    locationError.value = null;
    final updated = Set<Marker>.from(
      markers.where((m) => m.markerId.value != 'user'),
    );
    updated.add(
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(position.latitude, position.longitude),
        icon: selectedTravelMode.value == 'walking'
            ? (_walkingMarker ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ))
            : (_ridingMarker ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  )),
        infoWindow: InfoWindow(
          title: selectedTravelMode.value == 'walking'
              ? 'Your location · Walking'
              : 'Your location · Riding',
        ),
        flat: false,
        rotation: 0,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: 10,
      ),
    );
    markers.assignAll(updated);
  }

  void _onPosition(Position position) {
    if (_closed || !_usable(position)) return;
    _acceptPosition(position);
    final match = closestPointOnRoute(
      LatLng(position.latitude, position.longitude),
      _routePoints,
    );
    if (match == null) return;
    _updateProgress(position, match);
    _checkOffRoute(position, match);
    if (isNavigating.value && isFollowing.value) _followPosition(position);
  }

  Future<void> changeTravelMode(String mode) async {
    if (mode != 'walking' && mode != 'twoWheeler') return;
    if (mode == selectedTravelMode.value || isNavigating.value) return;
    selectedTravelMode.value = mode;
    _startTracking();
    final position = currentPosition.value;
    if (position != null) {
      _acceptPosition(position);
      await _loadRoute(position, replace: true);
    }
  }

  Future<void> retry() async {
    if (isLoading.value || isRouteLoading.value) return;
    await initialize();
  }

  Future<void> _loadRoute(
    Position position, {
    bool replace = false,
    bool reroute = false,
  }) async {
    final request = ++_requestId;
    isRouteLoading.value = true;
    routeError.value = null;
    if (replace) {
      _routePoints = const [];
      polylines.clear();
      remainingDistance.value = '--';
      estimatedDuration.value = '--';
    }
    try {
      final route = await RouteDirectionService.instance.getDirections(
        originLat: position.latitude,
        originLng: position.longitude,
        destLat: destLat,
        destLng: destLng,
        mode: selectedTravelMode.value,
      );
      if (_closed || request != _requestId) return;
      _routePoints = route.polylinePoints;
      _steps = route.steps;
      _routeDistance = route.distanceInMeters;
      _routeDurationSeconds = route.durationSeconds ?? 0;
      _offRouteSamples = 0;
      _arrived = false;
      final match = closestPointOnRoute(
        LatLng(position.latitude, position.longitude),
        _routePoints,
      );
      if (match != null) _updateProgress(position, match);
      if (!isNavigating.value) fitRoute();
    } catch (error) {
      if (_closed || request != _requestId) return;
      final message = error is RouteDirectionException
          ? error.message
          : 'Could not calculate a route. Retry.';
      routeError.value = reroute
          ? 'Rerouting failed. The previous route may be outdated. $message'
          : message;
    } finally {
      if (!_closed && request == _requestId) {
        isRouteLoading.value = false;
        isRerouting.value = false;
      }
    }
  }

  void _updateProgress(Position position, RouteMatch match) {
    if (_routePoints.length < 2) return;
    final destinationDistance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destLat,
      destLng,
    );
    if (isNavigating.value &&
        !_arrived &&
        destinationDistance <= math.max(25, position.accuracy)) {
      _arrived = true;
      isNavigating.value = false;
      isFollowing.value = false;
      Get.dialog<void>(
        AlertDialog(
          title: const Text('You have arrived'),
          content: Text('You have reached $destinationTitle.'),
          actions: [TextButton(onPressed: Get.back, child: const Text('Done'))],
        ),
      );
    }
    if (match.distanceMeters > math.max(35, position.accuracy * 1.5)) return;
    final remaining = <LatLng>[
      match.point,
      ..._routePoints.skip(match.segmentIndex + 1),
    ];
    if (remaining.length < 2) return;
    polylines.assignAll({
      Polyline(
        polylineId: const PolylineId('route_border'),
        points: remaining,
        color: const Color(0xFF174395),
        width: 9,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: 1,
      ),
      Polyline(
        polylineId: const PolylineId('route'),
        points: remaining,
        color: const Color(0xFF2776ED),
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: 2,
      ),
    });
    final fraction = match.routeLengthMeters > 0
        ? (1 - match.distanceAlongMeters / match.routeLengthMeters).clamp(
            0.0,
            1.0,
          )
        : 0.0;
    remainingDistance.value = LocationService.formatDistance(
      _routeDistance * fraction,
    );
    estimatedDuration.value = _routeDurationSeconds > 0
        ? _formatMinutes(_routeDurationSeconds * fraction)
        : '--';
    _updateInstruction(match);
  }

  void _updateInstruction(RouteMatch match) {
    for (var index = 1; index < _steps.length; index++) {
      final turn = closestPointOnRoute(
        _steps[index].startLocation,
        _routePoints,
      );
      if (turn == null ||
          turn.distanceAlongMeters <= match.distanceAlongMeters + 5) {
        continue;
      }
      currentInstruction.value = _steps[index].instruction;
      distanceToNextTurn.value = LocationService.formatDistance(
        turn.distanceAlongMeters - match.distanceAlongMeters,
      );
      return;
    }
    currentInstruction.value = 'Continue to $destinationTitle';
    distanceToNextTurn.value = remainingDistance.value;
  }

  void _checkOffRoute(Position position, RouteMatch match) {
    if (!isNavigating.value ||
        isRouteLoading.value ||
        position.accuracy > 50 ||
        _arrived) {
      return;
    }
    final threshold = math.max(40.0, position.accuracy * 1.5);
    if (match.distanceMeters <= threshold) {
      _offRouteSamples = 0;
      return;
    }
    if (++_offRouteSamples < 3) return;
    final now = DateTime.now();
    if (_lastReroute != null &&
        now.difference(_lastReroute!) < const Duration(seconds: 20)) {
      return;
    }
    _offRouteSamples = 0;
    _lastReroute = now;
    isRerouting.value = true;
    _loadRoute(position, reroute: true);
  }

  static String _formatMinutes(double seconds) {
    final minutes = (seconds / 60).ceil().clamp(1, 1000000);
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours hr' : '$hours hr $rest min';
  }

  void onMapCreated(GoogleMapController map) {
    _map = map;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_closed) fitRoute();
    });
  }

  void startNavigation() {
    if (!canStart) return;
    isNavigating.value = true;
    isFollowing.value = true;
    final position = currentPosition.value;
    if (position != null) _followPosition(position);
  }

  void stopNavigation() {
    isNavigating.value = false;
    isFollowing.value = false;
    fitRoute();
  }

  void onUserGesture() {
    if (isNavigating.value) isFollowing.value = false;
  }

  void recenter() {
    final position = currentPosition.value;
    if (position == null) return;
    isFollowing.value = isNavigating.value;
    _followPosition(position);
  }

  void _followPosition(Position position) {
    _map?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: selectedTravelMode.value == 'walking' ? 18 : 17,
          bearing: position.heading.isFinite && position.heading >= 0
              ? position.heading
              : 0,
          tilt: 45,
        ),
      ),
    );
  }

  void zoomIn() {
    onUserGesture();
    _map?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    onUserGesture();
    _map?.animateCamera(CameraUpdate.zoomOut());
  }

  void fitRoute() {
    if (_map == null) return;
    if (isNavigating.value) isFollowing.value = false;
    final points = _routePoints.isNotEmpty
        ? _routePoints
        : <LatLng>[
            if (currentPosition.value != null)
              LatLng(
                currentPosition.value!.latitude,
                currentPosition.value!.longitude,
              ),
            if (_validDestination) LatLng(destLat, destLng),
          ];
    if (points.isEmpty) return;
    if (points.length == 1) {
      _map?.animateCamera(CameraUpdate.newLatLngZoom(points.first, 15));
      return;
    }
    final minLat = points.map((p) => p.latitude).reduce(math.min);
    final maxLat = points.map((p) => p.latitude).reduce(math.max);
    final minLng = points.map((p) => p.longitude).reduce(math.min);
    final maxLng = points.map((p) => p.longitude).reduce(math.max);
    if ((maxLat - minLat).abs() < 0.0001 && (maxLng - minLng).abs() < 0.0001) {
      _map?.animateCamera(CameraUpdate.newLatLngZoom(points.first, 16));
      return;
    }
    _map?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        72,
      ),
    );
  }

  @override
  void onClose() {
    _closed = true;
    _requestId++;
    _positionSubscription?.cancel();
    _map?.dispose();
    super.onClose();
  }
}
