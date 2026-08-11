import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

/// "My Subscription" — surfaces the user's current plan, credit usage and
/// billing period from `GET /subscriptions/my`.
class MySubscriptionScreen extends StatelessWidget {
  const MySubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
    final MySubscriptionController controller =
        Get.find<MySubscriptionController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "My Subscription"),
      body: Obx(() {
        if (controller.showInitialShimmer && controller.subscription == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return ErrorStateWidget(
            message: controller.errorMessage!,
            onRetry: controller.fetchSubscription,
          );
        }

        final MySubscriptionModel? sub = controller.subscription;
        if (sub == null) {
          return _NoSubscription(colorScheme: colorScheme);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSubscription(isRefresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _PlanCard(sub: sub, colorScheme: colorScheme),
              if (sub.credits != null) ...[
                const SizedBox(height: 16),
                _CreditsCard(credits: sub.credits!, colorScheme: colorScheme),
              ],
              const SizedBox(height: 16),
              _BillingCard(sub: sub, colorScheme: colorScheme),
              // Offer cancel for any active plan (free included). Cancellation
              // is immediate — no grace period.
              if (sub.isActive) ...[
                const SizedBox(height: 24),
                _CancelButton(controller: controller, colorScheme: colorScheme),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ── Plan header ─────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final MySubscriptionModel sub;
  final ColorScheme colorScheme;

  const _PlanCard({required this.sub, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final Color accent = _statusColor(colorScheme, sub.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.workspace_premium_rounded, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.planName?.isNotEmpty == true
                          ? sub.planName!
                          : 'Subscription',
                      style: AppTextStyle.textLg(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: sub.status, accent: accent),
                  ],
                ),
              ),
            ],
          ),
          if (sub.formattedAmount.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  sub.formattedAmount,
                  style: AppTextStyle.textXl(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w700,
                  ),
                ),
                if (sub.billingType?.isNotEmpty == true)
                  Text(
                    ' / ${_billingLabel(sub.billingType!)}',
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Credits usage ───────────────────────────────────────────────────────────
class _CreditsCard extends StatelessWidget {
  final SubscriptionCredits credits;
  final ColorScheme colorScheme;

  const _CreditsCard({required this.credits, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Spotlight credits',
                style: AppTextStyle.textSm(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${credits.remaining} / ${credits.total}',
                style: AppTextStyle.textSm(
                  color: colorScheme.primary,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: credits.remainingFraction,
              minHeight: 8,
              // Neutral track that contrasts with the card in both themes; the
              // primary fill reads as "remaining".
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${credits.used} used · ${credits.remaining} remaining',
            style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Billing period ──────────────────────────────────────────────────────────
class _BillingCard extends StatelessWidget {
  final MySubscriptionModel sub;
  final ColorScheme colorScheme;

  const _BillingCard({required this.sub, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // Cancellation is immediate now, so an active recurring plan always renews.
    const String renewLabel = 'Renews on';

    return _SectionCard(
      colorScheme: colorScheme,
      child: Column(
        children: [
          if (sub.billingType?.isNotEmpty == true)
            _InfoRow(
              icon: Icons.receipt_long_rounded,
              label: 'Billing',
              value: _billingLabel(sub.billingType!),
              colorScheme: colorScheme,
            ),
          if (_formatDate(sub.currentPeriodEnd) != null) ...[
            if (sub.billingType?.isNotEmpty == true) const _RowDivider(),
            _InfoRow(
              icon: Icons.event_repeat_rounded,
              label: renewLabel,
              value: _formatDate(sub.currentPeriodEnd)!,
              colorScheme: colorScheme,
            ),
          ],
          if (_formatDate(sub.currentPeriodStart) != null) ...[
            const _RowDivider(),
            _InfoRow(
              icon: Icons.play_circle_outline_rounded,
              label: 'Started',
              value: _formatDate(sub.currentPeriodStart)!,
              colorScheme: colorScheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final MySubscriptionController controller;
  final ColorScheme colorScheme;

  const _CancelButton({required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // Own Obx so tapping cancel rebuilds *this* button (the screen's outer Obx
    // doesn't read isCancelling, so without this the loader never shows).
    return Obx(() {
      final bool isCancelling = controller.isCancelling;
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isCancelling ? null : () => _confirmCancel(context),
          child: isCancelling
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cancel subscription'),
        ),
      );
    });
  }

  void _confirmCancel(BuildContext context) {
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
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            onPressed: () {
              Get.back();
              controller.cancelSubscription();
            },
            child: const Text('Cancel it'),
          ),
        ],
      ),
    );
  }
}

// ── No subscription state ───────────────────────────────────────────────────
class _NoSubscription extends StatelessWidget {
  final ColorScheme colorScheme;

  const _NoSubscription({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const EmptyState(
          icon: Icons.workspace_premium_outlined,
          title: 'No active subscription',
          subtitle: 'Subscribe to unlock premium spotlight features.',
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () => Get.toNamed(AppRoutes.subscription),
              child: const Text('View plans'),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Small shared building blocks ────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Widget child;
  final ColorScheme colorScheme;

  const _SectionCard({required this.child, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // surfaceContainer is nearly identical to the scaffold surface on this
        // theme, so a solid outline + soft shadow (like the plan cards) is what
        // makes the container read in both light and dark.
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyle.textSm(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 24,
      color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color accent;

  const _StatusBadge({required this.status, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: AppTextStyle.textXs(color: accent, weight: FontWeight.w700),
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────
Color _statusColor(ColorScheme colorScheme, String status) {
  switch (status) {
    case 'active':
      return colorScheme.primary;
    case 'past_due':
    case 'incomplete':
      return colorScheme.error;
    default:
      return colorScheme.onSurfaceVariant;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'active':
      return 'ACTIVE';
    case 'past_due':
      return 'PAYMENT DUE';
    case 'incomplete':
      return 'INCOMPLETE';
    case 'cancelled':
    case 'canceled':
      return 'CANCELLED';
    default:
      return status.toUpperCase();
  }
}

String _billingLabel(String billingType) {
  switch (billingType.toLowerCase()) {
    case 'monthly':
      return 'month';
    case 'yearly':
    case 'annual':
      return 'year';
    default:
      return billingType;
  }
}

String? _formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return null;
  final DateTime? parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return null;
  return DateFormat('MMM d, yyyy').format(parsed.toLocal());
}
