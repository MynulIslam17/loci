import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/presentation/controllers/plans_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/billing_toggle_header.dart';
import 'package:loci/features/subscription/presentation/widgets/plans_section.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
    final PlansController controller = Get.find<PlansController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Subscription Plan"),
      body: AdaptiveRefresh(
        onRefresh: controller.refreshPlans,
        // A single CustomScrollView so the banner scrolls away above the plan
        // list while the billing toggle stays pinned. Reactivity is scoped to
        // the individual sections (toggle / plans) rather than the whole tree,
        // so switching billing period doesn't rebuild the pinned toggle.
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SubscriptionHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: BillingTogglePinnedHeader(
                backgroundColor: colorScheme.surface,
              ),
            ),
            const SliverToBoxAdapter(child: PlansSection()),
          ],
        ),
      ),
    );
  }
}
