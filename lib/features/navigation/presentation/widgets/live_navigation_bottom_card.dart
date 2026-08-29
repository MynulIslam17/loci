import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/navigation/presentation/controllers/live_navigation_controller.dart';
import 'package:loci/features/navigation/presentation/widgets/live_navigation_mode_pill.dart';

/// Bottom summary card with Travel Modes (🚗 Drive, 🏍️ Ride, 🚶 Walk), Remaining Distance, ETA, and Actions
class LiveNavigationBottomCard extends StatelessWidget {
  const LiveNavigationBottomCard({
    super.key,
    required this.controller,
    required this.colors,
    required this.isNavigating,
  });

  final LiveNavigationController controller;
  final ColorScheme colors;
  final bool isNavigating;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag indicator bar
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Destination Venue Name & Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.place_rounded,
                  color: const Color(0xFFEF4444),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.destinationTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textLg(
                        color: colors.onSurface,
                        weight: FontWeight.w700,
                      ),
                    ),
                    if (controller.locationLabel?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 1.h),
                      Text(
                        controller.locationLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textSm(
                          color: colors.onSurface.withValues(alpha: 0.65),
                          weight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Travel Mode Switcher Pills (Drive 🚗, Ride 🏍️, Walk 🚶)
          if (!isNavigating) ...[
            SizedBox(height: 12.h),
            Obx(() {
              final mode = controller.selectedTravelMode.value;
              return Row(
                children: [
                  LiveNavigationModePill(
                    icon: Icons.directions_car_rounded,
                    label: 'Drive',
                    isSelected: mode == 'driving',
                    activeColor: const Color(0xFF2563EB),
                    onTap: () => controller.changeTravelMode('driving'),
                    colors: colors,
                  ),
                  SizedBox(width: 8.w),
                  LiveNavigationModePill(
                    icon: Icons.two_wheeler_rounded,
                    label: 'Ride',
                    isSelected: mode == 'twoWheeler',
                    activeColor: const Color(0xFF10B981),
                    onTap: () => controller.changeTravelMode('twoWheeler'),
                    colors: colors,
                  ),
                  SizedBox(width: 8.w),
                  LiveNavigationModePill(
                    icon: Icons.directions_walk_rounded,
                    label: 'Walk',
                    isSelected: mode == 'walking',
                    activeColor: const Color(0xFFF59E0B),
                    onTap: () => controller.changeTravelMode('walking'),
                    colors: colors,
                  ),
                ],
              );
            }),
          ],

          SizedBox(height: 12.h),

          // Metrics Pills: Remaining Distance & Estimated Duration
          Obx(() {
            final distance = controller.remainingDistance.value.isNotEmpty
                ? controller.remainingDistance.value
                : '--';
            final duration = controller.estimatedDuration.value.isNotEmpty
                ? controller.estimatedDuration.value
                : '--';

            return Row(
              children: [
                Expanded(
                  child: _MetricBadge(
                    icon: Icons.route_rounded,
                    label: 'Remaining',
                    value: distance,
                    badgeColor: const Color(0xFF2563EB),
                    colors: colors,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _MetricBadge(
                    icon: Icons.schedule_rounded,
                    label: 'Est. Time',
                    value: duration,
                    badgeColor: const Color(0xFF10B981),
                    colors: colors,
                  ),
                ),
              ],
            );
          }),

          SizedBox(height: 14.h),

          // Action Button: Start / Exit Navigation (Full Width Production Design)
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: isNavigating
                  ? controller.stopInAppNavigation
                  : controller.startInAppNavigation,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isNavigating ? const Color(0xFFEF4444) : colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: Icon(
                isNavigating ? Icons.stop_rounded : Icons.navigation_rounded,
                size: 20.sp,
              ),
              label: Text(
                isNavigating ? 'Exit Nav' : 'Start Navigation',
                style: AppTextStyle.textMd(
                  color: Colors.white,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.badgeColor,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color badgeColor;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: badgeColor, size: 18.sp),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.textXs(
                  color: colors.onSurface.withValues(alpha: 0.55),
                  weight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
