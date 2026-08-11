import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_checkout_controller.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Banner shown at the top of the Subscription screen when the user already has
/// a subscription. Surfaces status + credits + renew/end date and lets them
/// cancel. Renders nothing when there is no subscription.
class ActivePlanBanner extends StatelessWidget {
  const ActivePlanBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;

    return Obx(() {
      final SubscriptionCheckoutController checkout =
          Get.find<SubscriptionCheckoutController>();
      // While the first `/my` fetch is in flight, show a placeholder so the
      // banner doesn't pop in after the page has already rendered.
      if (checkout.isLoadingSubscription) {
        return const _BannerShimmer();
      }
      final MySubscriptionModel? sub = checkout.mySubscription;
      if (sub == null) return const SizedBox.shrink();

      final bool isPastDue = sub.status == 'past_due';
      final Color accent = isPastDue ? colorScheme.error : colorScheme.primary;
      final String? periodText = _periodText(sub.currentPeriodEnd);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.12),
              accent.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPastDue
                        ? Icons.error_outline_rounded
                        : Icons.verified_rounded,
                    size: 22,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(sub.status),
                        style: AppTextStyle.textSm(
                          color: accent,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (periodText != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.event_repeat_rounded,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              periodText,
                              style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Spotlight credits pill.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        // Spendable balance = plan + stacked packs, summed by the
                        // backend into `credits.remaining`. `heroSpotlightCredits`
                        // is only this row's balance, so it's the fallback.
                        '${sub.credits?.remaining ?? sub.heroSpotlightCredits}',
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Offer cancel for any active plan (free included). Cancellation is
            // immediate now — there's no "ends on" grace period.
            if (sub.isActive) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: checkout.isCancelling
                      ? null
                      : () => _confirmCancel(context, checkout),
                  child: checkout.isCancelling
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cancel subscription'),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active plan';
      case 'past_due':
        return 'Payment failed — update your card';
      case 'incomplete':
        return 'Payment incomplete';
      default:
        return status;
    }
  }

  /// "Renews on …" for a recurring plan. Returns null for one-time packs (no
  /// period end). Cancellation is immediate now, so there's no "Ends on" state.
  String? _periodText(String? isoDate) {
    final String? date = _formatDate(isoDate);
    if (date == null) return null;
    return 'Renews on $date';
  }

  String? _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return null;
    final DateTime? parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return null;
    return DateFormat('MMM d, yyyy').format(parsed.toLocal());
  }

  void _confirmCancel(
    BuildContext context,
    SubscriptionCheckoutController checkout,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel subscription?'),
        content: const Text(
          'Your plan will be cancelled immediately and you\'ll lose access to '
          'paid features right away. Remaining paid days aren\'t refunded. You '
          'can resubscribe anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep plan'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              checkout.cancel();
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: const Text('Cancel it'),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown in the banner slot while the first `/my` fetch resolves —
/// matches the loaded banner's footprint so nothing jumps when it settles.
class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSkeleton.box(width: 40, height: 40),
              const SizedBox(width: 12),
              Expanded(child: AppSkeleton.box(width: 120, height: 16)),
              const SizedBox(width: 12),
              AppSkeleton.box(width: 44, height: 24),
            ],
          ),
          const SizedBox(height: 14),
          AppSkeleton.box(width: double.infinity, height: 42),
        ],
      ),
    );
  }
}
