import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/data/models/subscription/plan_response_model.dart';
import 'package:loci/presentation/controllers/subscription/subscription_checkout_controller.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isExpanded;
  final bool isMonthly;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isExpanded,
    required this.isMonthly,
    required this.onTap,
  });

  /// A plan is "current" when it matches the caller's active subscription —
  /// compared against both the stable slug id and the live Stripe product id,
  /// since `Subscription.planId` may be stored as either (see backend
  /// `getMySubscription`).
  bool _isCurrentPlan(dynamic sub) {
    if (sub == null || !(sub.isActive as bool)) return false;
    if (plan.amount == 0) return (sub.amount as int) == 0;
    final subPlanId = sub.planId as String?;
    return subPlanId != null &&
        (subPlanId == plan.id || subPlanId == plan.realProductId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isFree = plan.amount == 0;

    return GetBuilder<SubscriptionCheckoutController>(
      builder: (checkout) {
        final isCurrentPlan = _isCurrentPlan(checkout.mySubscription);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentPlan
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.1),
              width: isCurrentPlan ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: name + type chip ──────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: AppTextStyle.textMd(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isCurrentPlan) ...[
                      const _CurrentPlanBadge(),
                      const SizedBox(width: 8),
                    ],
                    _TypeChip(
                      label: isFree
                          ? 'Free'
                          : (isMonthly ? 'Monthly' : 'One-time'),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Price ─────────────────────────────────────────────────
                _PriceRow(
                  isFree: isFree,
                  amount: plan.amount,
                  isMonthly: isMonthly,
                  colorScheme: colorScheme,
                ),

                if (plan.heroSpotlightCredits > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.heroSpotlightCredits} spotlight credits',
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // ── Benefits reveal ───────────────────────────────────────
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? "Hide benefits" : "See benefits",
                          style: AppTextStyle.textSm(
                            color: colorScheme.primary,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: plan.features
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e,
                                      style: AppTextStyle.textXs(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),

                const SizedBox(height: 16),

                // ── Subscribe button (or "Current Plan" state) ────────────
                if (isCurrentPlan)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Current Plan",
                            style: AppTextStyle.textSm(
                              color: colorScheme.primary,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      final isProcessing = checkout.isProcessing(plan.id);
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            disabledBackgroundColor: colorScheme.primary
                                .withValues(alpha: 0.4),
                            disabledForegroundColor: colorScheme.onPrimary
                                .withValues(alpha: 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // Disable every card's button while any purchase is in flight.
                          onPressed: checkout.processingPlanId != null
                              ? null
                              : () => checkout.subscribe(plan.id),
                          child: isProcessing
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  isFree ? "Join Free" : "Subscribe",
                                  style: AppTextStyle.textSm(
                                    color: colorScheme.onPrimary,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bold badge marking the plan the caller is currently subscribed to.
class _CurrentPlanBadge extends StatelessWidget {
  const _CurrentPlanBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Current Plan',
        style: AppTextStyle.textXs(
          color: colorScheme.onPrimary,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Small rounded chip labelling the plan's billing type.
class _TypeChip extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _TypeChip({required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.textXs(
          color: colorScheme.primary,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Large amount with a muted period suffix (e.g. "$29" + "/month").
class _PriceRow extends StatelessWidget {
  final bool isFree;
  final int amount;
  final bool isMonthly;
  final ColorScheme colorScheme;

  const _PriceRow({
    required this.isFree,
    required this.amount,
    required this.isMonthly,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (isFree) {
      return Text(
        'Free',
        style: AppTextStyle.textXl(
          color: colorScheme.primary,
          weight: FontWeight.w700,
        ),
      );
    }

    // `amount` is in cents (Stripe convention) — matches how the admin
    // dashboard formats it. Displaying it raw showed "$5000" for a $50 plan.
    final dollars = amount / 100;
    final formatted = dollars == dollars.roundToDouble()
        ? dollars.toStringAsFixed(0)
        : dollars.toStringAsFixed(2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$$formatted',
          style: AppTextStyle.displayXs(
            color: colorScheme.onSurface,
            weight: FontWeight.w700,
          ),
        ),
        if (isMonthly) ...[
          const SizedBox(width: 4),
          Text(
            '/month',
            style: AppTextStyle.textSm(
              color: colorScheme.onSurfaceVariant,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
