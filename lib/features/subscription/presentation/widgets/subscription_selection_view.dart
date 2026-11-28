import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
      if (viewPlan) _openMyPlan();
      return;
    }
    await showSubscriptionInfo(context, copy);
    controller.clearMessages();
  }

  void _openMyPlan() {
    if (Get.previousRoute == AppRoutes.mySubscription) {
      Get.back<void>();
    } else {
      Get.offNamed<void>(AppRoutes.mySubscription);
    }
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
                Obx(() {
                  final MySubscriptionModel? current = _current;
                  if (current == null || current.isFreePlan) {
                    return const _BusinessPlanHero();
                  }
                  final String? productId =
                      MySubscriptionController.productIdFor(current);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CurrentPlanBanner(
                      subscription: current,
                      price: MySubscriptionController.displayPrice(
                        current,
                        storePrice: controller.productFor(productId)?.price,
                      ),
                      onManage: _openMyPlan,
                    ),
                  );
                }),
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

/// "Your plan" summary shown above the plans when the user already
/// subscribes, so the plans screen never looks like they have nothing.
class CurrentPlanBanner extends StatelessWidget {
  const CurrentPlanBanner({
    super.key,
    required this.subscription,
    required this.price,
    required this.onManage,
  });

  final MySubscriptionModel subscription;
  final String price;
  final VoidCallback onManage;

  static String? _date(String? iso) {
    final DateTime? parsed = iso == null ? null : DateTime.tryParse(iso);
    return parsed == null
        ? null
        : DateFormat('MMM d, yyyy').format(parsed.toLocal());
  }

  /// Second line: renewal / end date, or a scheduled switch.
  static String? detailFor(MySubscriptionModel sub) {
    final String? pending = sub.pendingPlanName;
    final String? end = _date(sub.currentPeriodEnd);
    if (pending != null && pending.isNotEmpty) {
      return end == null
          ? 'Switching to $pending at renewal'
          : 'Switching to $pending on $end';
    }
    if (sub.cancelAtPeriodEnd) {
      final String? ends = _date(sub.accessEndsAt);
      return ends == null ? 'Cancelled — ends at period end' : 'Ends on $ends';
    }
    if (sub.isPastDue) return 'Payment issue — update billing';
    return end == null ? null : 'Renews on $end';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    final String name = subscription.planName?.isNotEmpty == true
        ? subscription.planName!
        : 'Loci Business';
    final String? detail = detailFor(subscription);
    return Material(
      key: const Key('current_plan_banner'),
      color: colors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onManage,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: <Widget>[
              Icon(Icons.workspace_premium_rounded, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your plan',
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$name · $price',
                      style: AppTextStyle.textMd(
                        color: colors.onSurface,
                        weight: FontWeight.w700,
                      ),
                    ),
                    if (detail != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: AppTextStyle.textXs(
                          color: subscription.isPastDue
                              ? colors.error
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(onPressed: onManage, child: const Text('Manage')),
            ],
          ),
        ),
      ),
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
