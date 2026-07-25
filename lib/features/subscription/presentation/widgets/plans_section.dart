import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/subscription/presentation/controllers/plans_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/plan_list.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_shimmer.dart';
import 'package:loci/shared/widgets/error_state.dart';

/// Reactive plan area: loading shimmer, error state, or the plan list.
///
/// Reacts only to the plan/loading state — the pinned billing toggle has its
/// own [Obx], so a reload here never rebuilds the toggle.
class PlansSection extends StatelessWidget {
  const PlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlansController>();

    return Obx(() {
      if (controller.isLoading) {
        return const SubscriptionShimmer();
      }
      if (controller.errorMessage != null) {
        return ErrorStateWidget(
          message: controller.errorMessage!,
          onRetry: controller.refreshPlans,
        );
      }
      return PlansList(
        plans: controller.plans,
        isMonthly: controller.isMonthly,
        expandedIndex: controller.expandedIndex,
        onExpand: controller.toggleExpanded,
      );
    });
  }
}
