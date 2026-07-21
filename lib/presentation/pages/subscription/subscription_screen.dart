import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/subscription/plans_controller.dart';
import 'package:loci/presentation/controllers/subscription/subscription_checkout_controller.dart';
import 'package:loci/presentation/pages/subscription/widget/active_plan_banner.dart';
import 'package:loci/presentation/pages/subscription/widget/billing_toggle.dart';
import 'package:loci/presentation/pages/subscription/widget/plan_list.dart';
import 'package:loci/presentation/pages/subscription/widget/subscription_shimmer.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import '../../../core/enums/billing_type_enum.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isMonthly = true;
  int? _expandedIndex;

  final controller = Get.find<PlansController>();
  final checkoutController = Get.find<SubscriptionCheckoutController>();

  @override
  void initState() {
    super.initState();
    controller.fetchPlans(BillingType.monthly);
    checkoutController.fetchMySubscription();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Subscription Plan"),
      body: GetBuilder<PlansController>(
        builder: (ctrl) {
          return RefreshIndicator(
            onRefresh: () => controller.refreshPlans(
              _isMonthly ? BillingType.monthly : BillingType.oneTime,
            ),
            // Single CustomScrollView so the banner + billing toggle scroll
            // away above the plan list instead of staying pinned.
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Headline + banner scroll away with the content.
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grow your business',
                              style: AppTextStyle.textXl(
                                color: colorScheme.onSurface,
                                weight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pick a plan that fits — cancel anytime.',
                              style: AppTextStyle.textSm(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const ActivePlanBanner(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // Billing toggle stays pinned to the top while plans scroll.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedBillingToggle(
                    backgroundColor: colorScheme.surface,
                    isMonthly: _isMonthly,
                    onChanged: (value) {
                      if (value == _isMonthly) return;
                      setState(() => _isMonthly = value);

                      ctrl.fetchPlans(
                        value ? BillingType.monthly : BillingType.oneTime,
                      );
                    },
                  ),
                ),

                ..._buildPlansSlivers(ctrl),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPlansSlivers(PlansController ctrl) {
    if (ctrl.isLoading) {
      return const [
        SliverFillRemaining(child: SubscriptionShimmer()),
      ];
    }
    if (ctrl.errorMessage != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(ctrl.errorMessage!)),
        ),
      ];
    }
    return [
      PlansList(
        plans: ctrl.plans,
        isMonthly: _isMonthly,
        expandedIndex: _expandedIndex,
        onExpand: (index) {
          setState(() {
            _expandedIndex = _expandedIndex == index ? null : index;
          });
        },
      ),
    ];
  }
}

/// Keeps the billing toggle pinned at the top of the scroll view. The solid
/// [backgroundColor] ensures plan cards don't show through as they scroll under it.
class _PinnedBillingToggle extends SliverPersistentHeaderDelegate {
  final bool isMonthly;
  final ValueChanged<bool> onChanged;
  final Color backgroundColor;

  _PinnedBillingToggle({
    required this.isMonthly,
    required this.onChanged,
    required this.backgroundColor,
  });

  // Toggle is 56px tall (48 + 4px padding each side) + a little breathing room.
  static const double _height = 68;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
      child: BillingToggleSection(
        isMonthly: isMonthly,
        onChanged: onChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(_PinnedBillingToggle oldDelegate) {
    return isMonthly != oldDelegate.isMonthly ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}