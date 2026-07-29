import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/models/plan_response_model.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_checkout_controller.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';

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
  bool _isCurrentPlan(MySubscriptionModel? sub) {
    if (sub == null || !sub.isActive) return false;
    if (plan.amount == 0) return sub.amount == 0;
    final String? subPlanId = sub.planId;
    return subPlanId != null &&
        (subPlanId == plan.id || subPlanId == plan.realProductId);
  }

  /// True when this plan is a scheduled (not-yet-applied) downgrade — the
  /// caller's current plan keeps running until `currentPeriodEnd`.
  bool _isPendingPlan(MySubscriptionModel? sub) {
    if (sub == null) return false;
    final String? pendingId = sub.pendingPlanId;
    return pendingId != null && pendingId == plan.id;
  }

  /// Button label for a scheduled downgrade's target card. The switch takes
  /// effect at the current plan's period end, so show that date when known.
  String _pendingLabel(MySubscriptionModel? sub) {
    final String? iso = sub?.currentPeriodEnd;
    final DateTime? date = iso != null && iso.isNotEmpty
        ? DateTime.tryParse(iso)
        : null;
    if (date == null) return 'Starts at next renewal';
    return 'Starts ${DateFormat('MMM d').format(date.toLocal())}';
  }

  /// An upgrade is tapping a *recurring* plan that costs more than the active
  /// paid plan. The backend applies these in place and charges the prorated
  /// difference to the saved card without a PaymentSheet, so we confirm first.
  ///
  /// One-time credit packs are excluded (`isMonthly`): they stack on top and
  /// don't touch the recurring plan, so they're never an "upgrade" and must go
  /// straight to the PaymentSheet, not the recurring-upgrade dialog.
  bool _isUpgrade(MySubscriptionModel? sub) {
    return isMonthly &&
        sub != null &&
        sub.isActive &&
        sub.amount > 0 &&
        plan.amount > sub.amount;
  }

  /// Plan price for the confirm dialog copy, e.g. "$75/month" or "$75".
  String get _formattedPrice {
    final double dollars = plan.amount / 100;
    final String formatted = dollars == dollars.roundToDouble()
        ? dollars.toStringAsFixed(0)
        : dollars.toStringAsFixed(2);
    return isMonthly ? '\$$formatted/month' : '\$$formatted';
  }

  /// Confirms an upgrade (which charges immediately) before starting checkout;
  /// new/first-time paid plans skip straight to Stripe's PaymentSheet, which is
  /// its own confirmation.
  Future<void> _onSubscribePressed(
    BuildContext context,
    SubscriptionCheckoutController checkout,
  ) async {
    if (_isUpgrade(checkout.mySubscription)) {
      final bool confirmed = await showConfirmDialog(
        context,
        title: 'Upgrade to ${plan.name}?',
        message:
            'You\'ll switch to ${plan.name} now and be charged a prorated '
            'amount for the rest of this billing cycle, then $_formattedPrice '
            'going forward.',
        confirmText: 'Upgrade',
        icon: Icons.workspace_premium_rounded,
      );
      if (!confirmed) return;
    }

    await checkout.subscribe(plan.id);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
    final bool isFree = plan.amount == 0;

    return Obx(() {
      final SubscriptionCheckoutController checkout =
          Get.find<SubscriptionCheckoutController>();
      final bool isCurrentPlan = _isCurrentPlan(checkout.mySubscription);
      final bool isPendingPlan = _isPendingPlan(checkout.mySubscription);
      // Read these here (inside the Obx builder) so the observable is tracked —
      // if read lazily inside a nested Builder callback the loader never shows
      // because Obx doesn't register the dependency and won't rebuild.
      final bool isProcessing = checkout.isProcessing(plan.id);
      final bool anyProcessing = checkout.processingPlanId != null;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          // Full-strength outline: surfaceContainerHigh is nearly identical
          // to the scaffold surface in light mode (#FCFCFC on #FFFFFF), so
          // the border + shadow are what make the card visible.
          border: Border.all(
            color: isCurrentPlan
                ? colorScheme.primary
                : isPendingPlan
                ? colorScheme.primary.withValues(alpha: 0.5)
                : colorScheme.outline,
            width: isCurrentPlan || isPendingPlan ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrentPlan
                  ? colorScheme.primary.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: icon tile + name + billing hint + badge ───────
              Row(
                children: [
                  _PlanIcon(
                    isFree: isFree,
                    isCurrentPlan: isCurrentPlan,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: AppTextStyle.textMd(
                            color: colorScheme.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFree
                              ? 'Free forever'
                              : (isMonthly
                                    ? 'Billed monthly'
                                    : 'One-time payment'),
                          style: AppTextStyle.textXs(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentPlan)
                    const _CurrentPlanBadge()
                  else if (isPendingPlan)
                    const _ScheduledBadge()
                  else
                    _TypeChip(
                      label: isFree
                          ? 'Free'
                          : (isMonthly ? 'Monthly' : 'One-time'),
                      colorScheme: colorScheme,
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Price + spotlight credits ─────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PriceRow(
                    isFree: isFree,
                    amount: plan.amount,
                    isMonthly: isMonthly,
                    colorScheme: colorScheme,
                  ),
                  const Spacer(),
                  if (plan.heroSpotlightCredits > 0)
                    _CreditsChip(
                      credits: plan.heroSpotlightCredits,
                      colorScheme: colorScheme,
                    ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),

              // ── Benefits reveal ───────────────────────────────────────
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: plan.features
                        .map(
                          (String e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      e,
                                      style: AppTextStyle.textXs(
                                        color: colorScheme.onSurface,
                                      ),
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
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.6),
                      ),
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
              else if (isPendingPlan)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _pendingLabel(checkout.mySubscription),
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
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      disabledBackgroundColor: colorScheme.primary.withValues(
                        alpha: 0.4,
                      ),
                      disabledForegroundColor: colorScheme.onPrimary.withValues(
                        alpha: 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    // Disable every card's button while any purchase is in flight.
                    onPressed: anyProcessing
                        ? null
                        : () => _onSubscribePressed(context, checkout),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isFree ? "Join Free" : "Subscribe",
                                style: AppTextStyle.textSm(
                                  color: colorScheme.onPrimary,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: colorScheme.onPrimary,
                              ),
                            ],
                          ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// Rounded-square tile with a tier icon — gives each card a visual anchor.
class _PlanIcon extends StatelessWidget {
  final bool isFree;
  final bool isCurrentPlan;
  final ColorScheme colorScheme;

  const _PlanIcon({
    required this.isFree,
    required this.isCurrentPlan,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: isCurrentPlan ? 0.22 : 0.12),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        isFree ? Icons.storefront_rounded : Icons.workspace_premium_rounded,
        size: 22,
        color: colorScheme.primary,
      ),
    );
  }
}

/// Star pill showing how many spotlight credits the plan includes.
class _CreditsChip extends StatelessWidget {
  final int credits;
  final ColorScheme colorScheme;

  const _CreditsChip({required this.credits, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            '$credits credits',
            style: AppTextStyle.textXs(
              color: colorScheme.primary,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge marking the plan a scheduled downgrade will switch to at renewal.
class _ScheduledBadge extends StatelessWidget {
  const _ScheduledBadge();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Scheduled',
        style: AppTextStyle.textXs(
          color: colorScheme.primary,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Bold badge marking the plan the caller is currently subscribed to.
class _CurrentPlanBadge extends StatelessWidget {
  const _CurrentPlanBadge();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
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

    // `amount` is in cents (Stripe convention) — e.g. 5000 = $50, which is
    // exactly what Stripe charges. Show whole dollars when even, else 2dp.
    final double dollars = amount / 100;
    final String formatted = dollars == dollars.roundToDouble()
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
            weight: FontWeight.w800,
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
