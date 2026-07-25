import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/subscription/presentation/controllers/plans_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/billing_toggle.dart';

/// Keeps the billing toggle pinned at the top of the scroll view.
///
/// The toggle content is wrapped in its own [Obx] that reads *only*
/// `isMonthly`, and this delegate is created once by the screen (not inside a
/// reactive builder). That isolation is deliberate: switching tabs triggers a
/// plan reload, and previously the whole scroll view — including this pinned
/// header — was rebuilt by a single screen-wide `Obx`, resetting the toggle's
/// colour animation and its drop shadow mid-switch (the "colour flicker on the
/// tab bar"). Now a plan reload never touches the toggle.
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
    final controller = Get.find<PlansController>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        // Soft shadow only once plan cards start sliding underneath.
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
      child: Obx(
        () => BillingToggleSection(
          isMonthly: controller.isMonthly,
          onChanged: controller.selectBilling,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(BillingTogglePinnedHeader oldDelegate) {
    // isMonthly is handled by the nested Obx, so only a theme change matters.
    return backgroundColor != oldDelegate.backgroundColor;
  }
}
