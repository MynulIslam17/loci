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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isFree = plan.amount == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
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
                  Icon(Icons.star_rounded,
                      size: 16, color: colorScheme.primary),
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
                              Icon(Icons.check_circle_rounded,
                                  size: 16, color: colorScheme.primary),
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

            // ── Subscribe button ──────────────────────────────────────
            GetBuilder<SubscriptionCheckoutController>(
              builder: (checkout) {
                final isProcessing = checkout.isProcessing(plan.id);
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Disable every card's button while any purchase is in flight.
                    onPressed: checkout.processingPlanId != null
                        ? null
                        : () => checkout.subscribe(plan.id),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            isFree ? "Join Free" : "Subscribe",
                            style: AppTextStyle.textSm(
                              color: Colors.white,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$$amount',
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
