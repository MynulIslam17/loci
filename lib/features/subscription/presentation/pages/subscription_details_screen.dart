import 'dart:io';

import 'package:loci/shared/widgets/adaptive_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_dialogs.dart';
import 'package:loci/features/subscription/presentation/pages/subscription_success_screen.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_compare_tab.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_plan_details_tab.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';

/// Owns the tab bar, scroll area, and purchase action for plan confirmation.
class SubscriptionDetailsScreen extends GetView<SubscriptionController> {
  const SubscriptionDetailsScreen({super.key});

  static bool get _hasActivePlan =>
      Get.isRegistered<SubscriptionStatusController>() &&
      Get.find<SubscriptionStatusController>().subscription.value != null;

  /// Apple/Google already scheduled this plan for the next renewal — known
  /// from the backend (pendingPlanId) or from this device's store reply.
  static bool _isScheduled(SubscriptionController iap, String? productId) {
    if (productId == null) return false;
    if (iap.isSwitchScheduled(productId)) return true;
    final MySubscriptionModel? current =
        Get.isRegistered<SubscriptionStatusController>()
        ? Get.find<SubscriptionStatusController>().subscription.value
        : null;
    return MySubscriptionController.pendingProductIdFor(current) == productId;
  }

  static String? _withPeriod(String? price, String? billing) {
    if (price == null || price.isEmpty) return null;
    final bool yearly = (billing ?? '').toLowerCase().contains('year');
    return '$price / ${yearly ? 'year' : 'month'}';
  }

  Future<void> _subscribe(BuildContext context) async {
    final StoreSubscriptionPlan? plan = controller.selectedPlan.value;
    if (plan == null) return;
    if (!plan.isPaid) {
      Get.offAllNamed<void>(AppRoutes.bottomNav);
      return;
    }

    // Plan change: explain what happens before the store sheet appears.
    final MySubscriptionModel? current =
        Get.isRegistered<SubscriptionStatusController>()
        ? Get.find<SubscriptionStatusController>().subscription.value
        : null;
    if (current != null) {
      final String? currentProduct = MySubscriptionController.productIdFor(
        current,
      );
      final bool confirmed = await confirmSubscriptionAction(
        context,
        switchConfirmCopy(
          currentPlan: current.planName?.isNotEmpty == true
              ? current.planName!
              : 'your current plan',
          currentPrice: _withPeriod(
            controller.productFor(currentProduct)?.price ??
                current.formattedAmount,
            current.billingType,
          ),
          newPlan: plan.name,
          newPrice: _withPeriod(
            controller.productFor(plan.productId)?.price,
            plan.type.name,
          ),
          isIOS: Platform.isIOS,
        ),
        confirmText: 'Continue',
      );
      if (!confirmed) return;
    }

    // Success screen only after the backend verified (200) and the status
    // was refreshed — never on the store callback alone.
    final PurchaseOutcome outcome = await controller.subscribe();
    debugPrint('[subscription] purchase outcome → ${outcome.name}');
    if (outcome == PurchaseOutcome.success) {
      Get.off<void>(() => const SubscriptionSuccessScreen());
      return;
    }
    final DialogCopy? copy = purchaseResultCopy(
      outcome,
      info: controller.infoMessage.value,
      error: controller.errorMessage.value,
    );
    if (copy == null || !context.mounted) return;
    await showSubscriptionInfo(context, copy);
    controller.clearMessages();
    // A scheduled switch is done here — back to the plans, where the
    // button now reads "Switch scheduled".
    if (outcome == PurchaseOutcome.scheduled) Get.back<void>();
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
                text: _isScheduled(iap, plan.productId)
                    ? 'Switch scheduled'
                    : plan.isPaid
                    ? '${_hasActivePlan ? 'Switch' : 'Subscribe'} for '
                          '${iap.productFor(plan.productId)?.price ?? 'unavailable'}'
                    : 'Continue with Free',
                isLoading: controller.isPurchasing.value,
                // Pending / deferred / restore feedback.
                onPressed:
                    _isScheduled(iap, plan.productId) ||
                        (plan.isPaid && iap.productFor(plan.productId) == null)
                    ? null
                    : () => _subscribe(context),
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
                )
              else if (iap.infoMessage.value != null)
                Text(
                  iap.infoMessage.value!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(color: colors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
