import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';

class SubscriptionStatusBanner extends StatelessWidget {
  final MySubscriptionModel? subscription;
  final bool isLoading;
  final bool isCancelling;
  final VoidCallback? onCancel;

  const SubscriptionStatusBanner({
    super.key,
    required this.subscription,
    required this.isLoading,
    this.isCancelling = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: LinearProgressIndicator(),
      );
    }

    if (subscription == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: _InfoCard(
          icon: Icons.info_outline,
          title: 'How it works',
          message:
              'Pick a plan → pay securely with Stripe → we activate your subscription in a few seconds.',
          color: colorScheme.primaryContainer,
          onColor: colorScheme.onPrimaryContainer,
        ),
      );
    }

    final sub = subscription!;
    final periodEnd = sub.currentPeriodEnd != null
        ? DateTime.tryParse(sub.currentPeriodEnd!)
        : null;
    final dateLabel = periodEnd != null
        ? DateFormat.yMMMd().format(periodEnd)
        : null;

    if (sub.isPastDue) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: _InfoCard(
          icon: Icons.warning_amber_rounded,
          title: 'Payment failed',
          message:
              'Renewal payment failed. Update your payment method to keep access.',
          color: colorScheme.errorContainer,
          onColor: colorScheme.onErrorContainer,
        ),
      );
    }

    if (sub.isActive) {
      final renewalText = sub.cancelAtPeriodEnd && dateLabel != null
          ? 'Ends on $dateLabel'
          : dateLabel != null
          ? 'Renews on $dateLabel'
          : 'Active plan';

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active subscription',
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  renewalText,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sub.heroSpotlightCredits} spotlight credits (5 credits per ad)',
                  style: AppTextStyle.textXs(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                if (onCancel != null && !sub.cancelAtPeriodEnd) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isCancelling ? null : onCancel,
                      child: isCancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Cancel plan'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: _InfoCard(
        icon: Icons.hourglass_top,
        title: 'Checkout in progress',
        message: 'Complete payment to activate your plan.',
        color: colorScheme.secondaryContainer,
        onColor: colorScheme.onSecondaryContainer,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color onColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w700,
                      color: onColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: AppTextStyle.textXs(color: onColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
