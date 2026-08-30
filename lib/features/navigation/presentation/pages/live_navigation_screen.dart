import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/navigation/presentation/controllers/live_navigation_controller.dart';
import 'package:loci/features/navigation/presentation/widgets/live_navigation_bottom_card.dart';
import 'package:loci/features/navigation/presentation/widgets/live_navigation_hud.dart';

/// In-app live navigation screen: Global, modular, and reusable across all features
class LiveNavigationScreen extends StatelessWidget {
  const LiveNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveNavigationController());
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initialLat = controller.destLat != 0.0
        ? controller.destLat
        : (controller.currentPosition.value?.latitude ?? 23.7925);
    final initialLng = controller.destLng != 0.0
        ? controller.destLng
        : (controller.currentPosition.value?.longitude ?? 90.4078);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map View
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => controller.onUserTouchMap(),
            onPointerMove: (_) => controller.onUserTouchMap(),
            child: Obx(
              () => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(initialLat, initialLng),
                  zoom: 15.0,
                ),
                padding: EdgeInsets.only(
                  top: 105.h,
                  bottom: 215.h,
                ),
                markers: Set<Marker>.of(controller.markers),
                polylines: Set<Polyline>.of(controller.polylines),
                circles: Set<Circle>.of(controller.circles),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                buildingsEnabled: true,
                mapToolbarEnabled: false,
                onMapCreated: controller.onMapCreated,
                onCameraMoveStarted: controller.onCameraMoveStarted,
                onCameraMove: controller.onCameraMove,
              ),
            ),
          ),

          // 2. Loading Indicator Overlay
          Obx(() {
            if (!controller.isRouteLoading.value && !controller.isLoading.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 112.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14.w,
                        height: 14.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Updating live route...',
                        style: AppTextStyle.textSm(
                          color: colors.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // 3. Top Header Bar (HUD in navigation mode / Standard Top Bar in preview mode)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Obx(() {
                final isNavigating = controller.isNavigating.value;
                return isNavigating
                    ? LiveNavigationHud(
                        controller: controller,
                        colors: colors,
                      )
                    : _StandardTopBar(
                        controller: controller,
                        colors: colors,
                        isDark: isDark,
                      );
              }),
            ),
          ),

          // 4. Perspective 2D / 3D Toggle Pill (Shown ONLY during Active Navigation)
          Obx(() {
            final isNavigating = controller.isNavigating.value;
            if (!isNavigating) {
              return const SizedBox.shrink();
            }

            return Positioned(
              top: 116.h,
              right: 16.w,
              child: _PerspectiveToggleBtn(
                controller: controller,
                colors: colors,
              ),
            );
          }),

          // 5. Re-center Pill Button (During Active Navigation when user zooms/pans)
          Obx(() {
            final isNavigating = controller.isNavigating.value;
            final isPanning = controller.isUserPanning.value;
            if (!isNavigating || !isPanning) {
              return const SizedBox.shrink();
            }

            return Positioned(
              bottom: 175.h,
              right: 16.w,
              child: GestureDetector(
                onTap: controller.recenterOnUser,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        size: 16.sp,
                        color: colors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Re-center',
                        style: AppTextStyle.textSm(
                          color: colors.primary,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // 6. Floating Action Buttons (In Preview mode before starting navigation)
          Obx(() {
            final isNavigating = controller.isNavigating.value;
            if (isNavigating) {
              return const SizedBox.shrink();
            }

            return Positioned(
              right: 16.w,
              bottom: 275.h + 14.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapActionButton(
                    icon: Icons.crop_free_rounded,
                    tooltip: 'Fit full route',
                    onTap: controller.fitCameraToBounds,
                    colors: colors,
                  ),
                  SizedBox(height: 10.h),
                  _MapActionButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Recenter on me',
                    iconColor: colors.primary,
                    onTap: controller.recenterOnUser,
                    colors: colors,
                  ),
                ],
              ),
            );
          }),

          // 5. Bottom Navigation Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              return LiveNavigationBottomCard(
                controller: controller,
                colors: colors,
                isNavigating: controller.isNavigating.value,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StandardTopBar extends StatelessWidget {
  const _StandardTopBar({
    required this.controller,
    required this.colors,
    required this.isDark,
  });

  final LiveNavigationController controller;
  final ColorScheme colors;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MapActionButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Get.back(),
          colors: colors,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: isDark ? 0.92 : 0.98),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Route to ${controller.destinationTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textSm(
                      color: colors.onSurface,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.onTap,
    required this.colors,
    this.iconColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colors;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(
              child: Icon(
                icon,
                color: iconColor ?? colors.onSurface,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerspectiveToggleBtn extends StatelessWidget {
  const _PerspectiveToggleBtn({
    required this.controller,
    required this.colors,
  });

  final LiveNavigationController controller;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final is3D = controller.is3DMode.value;
      return Container(
        height: 28.h,
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2D Segment
            _PerspectiveSegment(
              label: '2D',
              isSelected: !is3D,
              onTap: () => controller.setPerspectiveMode(false),
              colors: colors,
            ),
            SizedBox(width: 1.w),
            // 3D Segment
            _PerspectiveSegment(
              label: '3D',
              isSelected: is3D,
              onTap: () => controller.setPerspectiveMode(true),
              colors: colors,
            ),
          ],
        ),
      );
    });
  }
}

class _PerspectiveSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colors;

  const _PerspectiveSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyle.textXs(
              color: isSelected ? Colors.white : colors.onSurface.withValues(alpha: 0.65),
              weight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
