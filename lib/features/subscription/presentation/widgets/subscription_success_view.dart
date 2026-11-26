import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class SubscriptionSuccessView extends StatelessWidget {
  const SubscriptionSuccessView({
    super.key,
    required this.controller,
    required this.onBackToPlans,
  });

  final SubscriptionController controller;
  final VoidCallback onBackToPlans;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Column(
          children: <Widget>[
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF16A36A).withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: Color(0xFF16A36A),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'You\'re subscribed',
              textAlign: TextAlign.center,
              style: AppTextStyle.displayXs(
                color: colors.onSurface,
                weight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              final StoreSubscriptionPlan? plan = controller.selectedPlan.value;
              return Text(
                plan == null
                    ? 'Your Loci Business plan is active.'
                    : 'Your ${plan.name} plan is active.',
                textAlign: TextAlign.center,
                style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
              );
            }),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF246BFD).withValues(alpha: .07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF246BFD),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final MySubscriptionModel? sub =
                          Get.isRegistered<SubscriptionStatusController>()
                          ? Get.find<SubscriptionStatusController>()
                                .subscription
                                .value
                          : null;
                      return Text(
                        sub == null
                            ? 'Paid features are now unlocked for all your businesses.'
                            : 'Paid features are unlocked for all your businesses. '
                                  'You have ${sub.remainingCredits} Spotlight credits.',
                        style: AppTextStyle.textXs(
                          color: colors.onSurfaceVariant,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Done',
              onPressed: onBackToPlans,
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
