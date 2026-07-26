import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_checkout_controller.dart';

/// Banner shown at the top of the Subscription screen when the user already has
/// a subscription. Surfaces status + credits + renew/end date and lets them
/// cancel. Renders nothing when there is no subscription.
class ActivePlanBanner extends StatelessWidget {
  const ActivePlanBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Obx(() {
      final checkout = Get.find<SubscriptionCheckoutController>();
      final sub = checkout.mySubscription;
      if (sub == null) return const SizedBox.shrink();

      final isPastDue = sub.status == 'past_due';
      final accent = isPastDue ? colorScheme.error : colorScheme.primary;
      final periodText = _periodText(
        sub.cancelAtPeriodEnd,
        sub.currentPeriodEnd,
      );

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
                        '${sub.heroSpotlightCredits}',
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

            // Offer cancel for any active plan (free included). Hidden once the
            // plan is already set to end — the "Ends on …" line covers that.
            if (sub.isActive && !sub.cancelAtPeriodEnd) ...[
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

  /// "Renews on …" for a recurring plan, or "Ends on …" when cancellation is
  /// scheduled. Returns null for one-time packs (no period end).
  String? _periodText(bool cancelAtPeriodEnd, String? isoDate) {
    final date = _formatDate(isoDate);
    if (date == null) return null;
    return cancelAtPeriodEnd ? 'Ends on $date' : 'Renews on $date';
  }

  String? _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return null;
    final parsed = DateTime.tryParse(isoDate);
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
          'Your plan stays active until the end of the current billing period. '
          'You can resubscribe anytime.',
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
