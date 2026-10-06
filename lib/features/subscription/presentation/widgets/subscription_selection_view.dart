import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_plan_card.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class SubscriptionSelectionView extends StatelessWidget {
  const SubscriptionSelectionView({
    super.key,
    required this.controller,
    required this.onContinue,
  });

  final SubscriptionController controller;
  final VoidCallback onContinue;

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
                Obx(
                  () => Column(
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
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomButton(
                      text: plan == null
                          ? 'Choose a plan'
                          : 'Continue with ${plan.name}',
                      onPressed:
                          plan == null ||
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
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.restorePurchases,
                      child: const Text('Restore Purchases'),
                    ),
                    if (controller.errorMessage.value != null)
                      Text(
                        controller.errorMessage.value!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textXs(color: colors.error),
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
