import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/presentation/controllers/plans_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/billing_toggle.dart';

/// Keeps the billing toggle pinned at the top of the scroll view with platform-adapted aesthetics:
/// - **iOS:** Frosted glass [BackdropFilter] with live content blur as cards slide underneath.
/// - **Android:** Clean elevated surface container with dynamic overlap shadow.
class BillingTogglePinnedHeader extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;

  BillingTogglePinnedHeader({required this.backgroundColor});

  // Toggle is 56px tall (48 + 4px padding each side) + a little breathing room.
  static const double _height = 68;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final PlansController controller = Get.find<PlansController>();
    final isIOS = context.isCupertino;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final toggleContent = Obx(
      () => BillingToggleSection(
        isMonthly: controller.isMonthly,
        onChanged: controller.selectBilling,
      ),
    );

    if (isIOS) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark
                  ? backgroundColor.withValues(alpha: 0.82)
                  : backgroundColor.withValues(alpha: 0.88),
              border: overlapsContent
                  ? Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(
                          alpha: isDark ? 0.2 : 0.35,
                        ),
                        width: 0.5,
                      ),
                    )
                  : null,
            ),
            child: toggleContent,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: toggleContent,
    );
  }

  @override
  bool shouldRebuild(BillingTogglePinnedHeader oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}
