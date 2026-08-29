import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/navigation/presentation/controllers/live_navigation_controller.dart';

/// Top HUD Banner showing current turn instruction, maneuver icon, and live GPS status
class LiveNavigationHud extends StatelessWidget {
  const LiveNavigationHud({
    super.key,
    required this.controller,
    required this.colors,
  });

  final LiveNavigationController controller;
  final ColorScheme colors;

  IconData _getManeuverIcon(String maneuver) {
    final m = maneuver.toLowerCase();
    if (m.contains('left')) return Icons.turn_left_rounded;
    if (m.contains('right')) return Icons.turn_right_rounded;
    if (m.contains('uturn') || m.contains('u-turn')) return Icons.u_turn_left_rounded;
    if (m.contains('flag') || m.contains('arrive')) return Icons.sports_score_rounded;
    return Icons.straight_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Slate HUD
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() {
            final maneuver = controller.currentManeuver.value;
            final isArrival = controller.isUserNearDestination.value;

            return Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isArrival ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getManeuverIcon(maneuver),
                color: Colors.white,
                size: 22.sp,
              ),
            );
          }),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(() {
              final instruction = controller.currentInstruction.value.isNotEmpty
                  ? controller.currentInstruction.value
                  : 'Navigating to ${controller.destinationTitle}';
              final distToTurn = controller.distanceToNextTurn.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    instruction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textSm(
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    distToTurn.isNotEmpty
                        ? 'In $distToTurn • Compass & GPS Active'
                        : 'Follow the blue route • Live Active',
                    style: AppTextStyle.textXs(
                      color: Colors.white.withValues(alpha: 0.7),
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
          IconButton(
            onPressed: controller.stopInAppNavigation,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Exit navigation',
          ),
        ],
      ),
    );
  }
}
