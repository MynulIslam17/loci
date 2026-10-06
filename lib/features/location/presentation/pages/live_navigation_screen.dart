import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/location/presentation/controllers/live_navigation_controller.dart';
import 'package:loci/features/location/presentation/widgets/navigation_route_sheet.dart';

/// One route from the user's current position to an event or route location.
class LiveNavigationScreen extends StatefulWidget {
  const LiveNavigationScreen({super.key});

  @override
  State<LiveNavigationScreen> createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  late final LiveNavigationController _controller;
  double _sheetExtent = 0.40;
  Timer? _fitAfterDrag;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LiveNavigationController>();
  }

  @override
  void dispose() {
    _fitAfterDrag?.cancel();
    super.dispose();
  }

  bool _onSheetMoved(DraggableScrollableNotification notice) {
    if ((notice.extent - _sheetExtent).abs() >= 0.015) {
      setState(() => _sheetExtent = notice.extent);
    }
    _fitAfterDrag?.cancel();
    _fitAfterDrag = Timer(const Duration(milliseconds: 240), () {
      if (mounted && !_controller.isNavigating.value) {
        _controller.fitRoute();
      }
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final colors = context.colorScheme;
    final mapBottomClearance =
        MediaQuery.sizeOf(context).height * _sheetExtent + 12;
    return Scaffold(
      body: Stack(
        children: [
          if (controller.isMapConfigured)
            Listener(
              onPointerMove: (_) => controller.onUserGesture(),
              child: Obx(
                () => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      (controller.destLat != 0 || controller.destLng != 0) &&
                              controller.destLat.abs() <= 90
                          ? controller.destLat
                          : 23.7925,
                      (controller.destLat != 0 || controller.destLng != 0) &&
                              controller.destLng.abs() <= 180
                          ? controller.destLng
                          : 90.4078,
                    ),
                    zoom: 14,
                  ),
                  onMapCreated: controller.onMapCreated,
                  markers: Set<Marker>.of(controller.markers),
                  polylines: Set<Polyline>.of(controller.polylines),
                  padding: EdgeInsets.only(
                    top:
                        MediaQuery.paddingOf(context).top +
                        (controller.isNavigating.value ? 180 : 80),
                    bottom: mapBottomClearance,
                  ),
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            )
          else
            ColoredBox(
              color: colors.surfaceContainer,
              child: const Center(child: Text('Map unavailable in this build')),
            ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _MapButton(
                        icon: const BackButtonIcon(),
                        tooltip: 'Back',
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: _cardDecoration(colors),
                          child: Text(
                            'To ${controller.destinationTitle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (!controller.isNavigating.value) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14213D),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.navigation_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.currentInstruction.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (controller
                                    .distanceToNextTurn
                                    .value
                                    .isNotEmpty)
                                  Text(
                                    controller.distanceToNextTurn.value,
                                    style: const TextStyle(
                                      color: Color(0xFFD6E4FF),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          Positioned(
            left: 16,
            bottom: mapBottomClearance,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_sheetExtent < 0.55) ...[
                  _MapButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Zoom in',
                    onPressed: controller.zoomIn,
                  ),
                  const SizedBox(height: 8),
                  _MapButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Zoom out',
                    onPressed: controller.zoomOut,
                  ),
                  const SizedBox(height: 8),
                ],
                _MapButton(
                  icon: const Icon(Icons.my_location),
                  tooltip: 'Recenter',
                  onPressed: controller.recenter,
                ),
                if (_sheetExtent < 0.55) ...[
                  const SizedBox(height: 8),
                  _MapButton(
                    icon: const Icon(Icons.fit_screen),
                    tooltip: 'Show route',
                    onPressed: controller.fitRoute,
                  ),
                ],
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: _onSheetMoved,
              child: DraggableScrollableSheet(
                initialChildSize: 0.40,
                minChildSize: 0.25,
                maxChildSize: 0.68,
                snap: true,
                snapSizes: const [0.25, 0.40, 0.68],
                expand: false,
                builder: (context, sheetScrollController) => NavigationRouteSheet(
                  controller: controller,
                  scrollController: sheetScrollController,
                ),
              ),
            ),
          ),

          Obx(
            () => controller.isRerouting.value
                ? Stack(
                    children: [
                      const ModalBarrier(
                        color: Color(0x66000000),
                        dismissible: false,
                      ),
                      Center(
                        child: AlertDialog(
                          title: const Text('You are off route'),
                          content: const Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text('Recalculating the best route...'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(ColorScheme colors) => BoxDecoration(
  color: colors.surface,
  borderRadius: BorderRadius.circular(18),
  boxShadow: const [
    BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 4)),
  ],
);

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    elevation: 3,
    color: Theme.of(context).colorScheme.surface,
    shape: const CircleBorder(),
    child: IconButton(icon: icon, tooltip: tooltip, onPressed: onPressed),
  );
}
