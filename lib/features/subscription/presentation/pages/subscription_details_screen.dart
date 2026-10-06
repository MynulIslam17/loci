import 'package:loci/shared/widgets/adaptive_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/pages/subscription_success_screen.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_compare_tab.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_plan_details_tab.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';

/// Owns the tab bar, scroll area, and purchase action for plan confirmation.
class SubscriptionDetailsScreen extends GetView<SubscriptionController> {
  const SubscriptionDetailsScreen({super.key});

  Future<void> _subscribe() async {
    if (controller.selectedPlan.value?.isPaid == false) {
      Get.offAllNamed<void>(AppRoutes.bottomNav);
      return;
    }
    final bool success = await controller.subscribe();
    if (success) Get.off<void>(() => const SubscriptionSuccessScreen());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          centerTitle: true,
          title: Text(
            'Loci Business',
            style: AppTextStyle.textLg(weight: FontWeight.w800),
          ),
        ),
        body: Obx(() {
          final StoreSubscriptionPlan? plan = controller.selectedPlan.value;
          if (plan == null) return const SizedBox.shrink();

          return Column(
            children: <Widget>[
              ColoredBox(
                color: colors.surface,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: AdaptiveTabBar(
                    labels: _tabLabels,
                    style: AdaptiveTabBarStyle.pill,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    SubscriptionCompareTab(plans: controller.plans),
                    SubscriptionPlanDetailsTab(plan: plan),
                  ],
                ),
              ),
              _buildPurchaseAction(context, plan),
            ],
          );
        }),
      ),
    );
  }

  static const List<String> _tabLabels = <String>[
    'Compare Plans',
    'Plan Details',
  ];

  Widget _buildPurchaseAction(
    BuildContext context,
    StoreSubscriptionPlan plan,
  ) {
    final ColorScheme colors = context.colorScheme;
    final SubscriptionController iap = controller;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: .6)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomButton(
                text: plan.isPaid
                    ? 'Subscribe for ${iap.productFor(plan.productId)?.price ?? 'unavailable'}'
                    : 'Continue with Free',
                isLoading: controller.isPurchasing.value,
                onPressed: plan.isPaid && iap.productFor(plan.productId) == null
                    ? null
                    : _subscribe,
                borderRadius: 16,
              ),
              const SizedBox(height: 8),
              Text(
                plan.isPaid
                    ? 'Billed by the App Store or Google Play.'
                    : 'No payment is required for the Free plan.',
                textAlign: TextAlign.center,
                style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
              ),
              if (iap.errorMessage.value != null)
                Text(
                  iap.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(color: colors.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


