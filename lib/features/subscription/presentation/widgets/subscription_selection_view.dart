import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_plan_card.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_dialogs.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';

/// Label and enabled state of the plans screen's main button, given the
/// selected plan and the user's current server-side subscription. Pure for
/// testing.
({String label, bool enabled}) planButtonState({
  required String? selectedName,
  required String? selectedProductId,
  required bool selectedIsPaid,
  required MySubscriptionModel? current,
  String? scheduledProductId,
}) {
  if (selectedName == null) return (label: 'Choose a plan', enabled: false);
  if (current != null) {
    final String? currentProduct = MySubscriptionController.productIdFor(
      current,
    );
    if (selectedProductId != null && selectedProductId == currentProduct) {
      return (label: 'Your current plan', enabled: false);
    }
    if (!selectedIsPaid) {
      return (label: 'Included in your plan', enabled: false);
    }
    // Scheduled per the backend (pendingPlanId) or this device's store reply.
    if (selectedProductId != null &&
        (selectedProductId == scheduledProductId ||
            selectedProductId ==
                MySubscriptionController.pendingProductIdFor(current))) {
      return (label: 'Switch scheduled', enabled: false);
    }
    return (label: 'Switch to $selectedName', enabled: true);
  }
  return (label: 'Continue with $selectedName', enabled: true);
}

class SubscriptionSelectionView extends StatelessWidget {
  const SubscriptionSelectionView({
    super.key,
    required this.controller,
    required this.onContinue,
  });

  final SubscriptionController controller;
  final VoidCallback onContinue;

  Future<void> _restore(BuildContext context) async {
    final RestoreOutcome outcome = await controller.restorePurchases();
    if (!context.mounted) return;
    final DialogCopy copy = restoreResultCopy(
      outcome,
      info: controller.infoMessage.value,
      error: controller.errorMessage.value,
      isIOS: Platform.isIOS,
    );
    if (outcome == RestoreOutcome.restored) {
      final bool viewPlan = await confirmSubscriptionAction(
        context,
        copy,
        confirmText: 'View my plan',
        cancelText: 'Close',
        icon: Icons.check_circle_outline_rounded,
      );
      controller.clearMessages();
      if (!viewPlan) return;
      if (Get.previousRoute == AppRoutes.mySubscription) {
        Get.back<void>();
      } else {
        Get.offNamed<void>(AppRoutes.mySubscription);
      }
      return;
    }
    await showSubscriptionInfo(context, copy);
    controller.clearMessages();
  }

  MySubscriptionModel? get _current =>
      Get.isRegistered<SubscriptionStatusController>()
      ? Get.find<SubscriptionStatusController>().subscription.value
      : null;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: <Widget>[
                const _BusinessPlanHero(),
                const SizedBox(height: 26),
                Obx(() {
                  final String? currentProduct =
                      MySubscriptionController.productIdFor(_current);
                  return Column(
                    children: controller.plans
                        .map(
                          (StoreSubscriptionPlan plan) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SubscriptionPlanCard(
                              plan: plan,
                              isSelected:
                                  controller.selectedPlan.value?.id == plan.id,
                              onTap: () => controller.selectPlan(plan),
                              storePrice: controller
                                  .productFor(plan.productId)
                                  ?.price,
                              isCurrent:
                                  plan.productId != null &&
                                  plan.productId == currentProduct,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(color: colors.surface),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Obx(() {
                final StoreSubscriptionPlan? plan =
                    controller.selectedPlan.value;
                final ({String label, bool enabled}) button = planButtonState(
                  selectedName: plan?.name,
                  selectedProductId: plan?.productId,
                  selectedIsPaid: plan?.isPaid ?? false,
                  current: _current,
                  scheduledProductId: controller.scheduledSwitchProductId.value,
                );
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomButton(
                      text: button.label,
                      onPressed:
                          plan == null ||
                              !button.enabled ||
                              (plan.isPaid &&
                                  (controller.productFor(plan.productId) ==
                                          null ||
                                      controller.isPurchasing.value))
                          ? null
                          : onContinue,
                      borderRadius: 16,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed:
                          controller.isLoading.value ||
                              controller.isRestoring.value ||
                              controller.isPurchasing.value
                          ? null
                          : () => _restore(context),
                      child: Text(
                        controller.isRestoring.value
                            ? 'Restoring…'
                            : 'Restore Purchases',
                      ),
                    ),
                    if (controller.errorMessage.value != null) ...<Widget>[
                      Text(
                        controller.errorMessage.value!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textXs(color: colors.error),
                      ),
                      if (controller.plansUnavailable &&
                          !controller.isLoading.value)
                        TextButton.icon(
                          onPressed: controller.retryLoadingPlans,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Try again'),
                        ),
                    ] else if (controller.infoMessage.value != null)
                      Text(
                        controller.infoMessage.value!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textXs(color: colors.primary),
                      ),
                    Text(
                      'You can change or cancel your subscription anytime from the App Store or Google Play.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _BusinessPlanHero extends StatelessWidget {
  const _BusinessPlanHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: <Widget>[
          Text(
            'Grow Your Business\nwith Loci',
            textAlign: TextAlign.center,
            style: AppTextStyle.displayXs(
              color: context.colorScheme.onSurface,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get the tools to create events, routes, raffles, and promote your business in the community.',
            textAlign: TextAlign.center,
            style: AppTextStyle.textSm(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
