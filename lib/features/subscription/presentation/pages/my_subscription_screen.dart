import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_shimmer.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
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
          return const MySubscriptionShimmer();
        }

        // Network error ≠ free plan: only show the error page when there is
        // no known status yet; otherwise keep the last one with a retry.
        if (controller.errorMessage != null && !controller.hasLoaded) {
          return ErrorStateWidget(
            message: controller.errorMessage!,
            onRetry: controller.fetchSubscription,
          );
        }

        final MySubscriptionModel? sub = controller.subscription;
        if (sub == null) {
          return AdaptiveRefresh(
            onRefresh: () => controller.fetchSubscription(isRefresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (controller.errorMessage != null)
                  _RetryBanner(controller: controller, colorScheme: colorScheme),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: _NoSubscription(colorScheme: colorScheme),
                ),
              ],
            ),
          );
        }

        return AdaptiveRefresh(
          onRefresh: () => controller.fetchSubscription(isRefresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.errorMessage != null) ...[
                _RetryBanner(controller: controller, colorScheme: colorScheme),
                const SizedBox(height: 12),
              ],
              if (sub.inGracePeriod) ...[
                _NoticeBanner(
                  icon: Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  colorScheme: colorScheme,
                  text:
                      'Payment problem — update your payment method in the '
                      '${_storeName(sub)} to keep your plan.',
                ),
                const SizedBox(height: 12),
              ],
              if (sub.cancelAtPeriodEnd &&
                  _formatDate(sub.accessEndsAt) != null) ...[
                _NoticeBanner(
                  icon: Icons.event_busy_rounded,
                  color: colorScheme.primary,
                  colorScheme: colorScheme,
                  text:
                      'Your plan ends on ${_formatDate(sub.accessEndsAt)}. '
                      'You keep all paid features until then.',
                ),
                const SizedBox(height: 12),
              ],
              _PlanCard(sub: sub, colorScheme: colorScheme),
              if (sub.credits != null) ...[
                const SizedBox(height: 16),
                _CreditsCard(
                  credits: sub.credits!,
                  resetsOn: _formatDate(sub.creditsExpireAt),
                  colorScheme: colorScheme,
                ),
              ],
              const SizedBox(height: 16),
              _BillingCard(sub: sub, colorScheme: colorScheme),
              const SizedBox(height: 24),
              _ManageButton(
                controller: controller,
                sub: sub,
                colorScheme: colorScheme,
              ),
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
  final String? resetsOn;
  final ColorScheme colorScheme;

  const _CreditsCard({
    required this.credits,
    required this.colorScheme,
    this.resetsOn,
  });

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
          if (resetsOn != null) ...[
            const SizedBox(height: 4),
            Text(
              'Credits reset on $resetsOn · unused credits don\'t roll over',
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
          ],
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
    // A cancelled store plan stays active until the paid-through date.
    final String renewLabel = sub.cancelAtPeriodEnd ? 'Access ends' : 'Renews on';
    final String? endDate = _formatDate(
      sub.cancelAtPeriodEnd ? sub.accessEndsAt : sub.currentPeriodEnd,
    );

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
          if (endDate != null) ...[
            if (sub.billingType?.isNotEmpty == true) const _RowDivider(),
            _InfoRow(
              icon: Icons.event_repeat_rounded,
              label: renewLabel,
              value: endDate,
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

/// Store plans can't be cancelled in-app: "Manage subscription" opens the
/// App Store / Google Play page. Legacy Stripe plans keep the old cancel.
class _ManageButton extends StatelessWidget {
  final MySubscriptionController controller;
  final MySubscriptionModel sub;
  final ColorScheme colorScheme;

  const _ManageButton({
    required this.controller,
    required this.sub,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool legacy = sub.provider != null && !sub.isStoreManaged;
    return Obx(() {
      final bool busy = controller.isOpeningStore || controller.isCancelling;
      final String label = legacy
          ? 'Cancel subscription'
          : sub.cancelAtPeriodEnd
          ? 'Resubscribe'
          : 'Manage subscription';
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: legacy ? colorScheme.error : colorScheme.primary,
            side: BorderSide(
              color: (legacy ? colorScheme.error : colorScheme.primary)
                  .withValues(alpha: 0.4),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: busy
              ? null
              : legacy
              ? () => _confirmLegacyCancel(context)
              : controller.manageSubscription,
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      );
    });
  }

  void _confirmLegacyCancel(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel subscription?'),
        content: const Text(
          'Your plan will stop renewing. Access continues through the current paid period.',
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
              controller.cancelLegacySubscription();
            },
            child: const Text('Cancel it'),
          ),
        ],
      ),
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final ColorScheme colorScheme;

  const _NoticeBanner({
    required this.icon,
    required this.color,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.textSm(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryBanner extends StatelessWidget {
  final MySubscriptionController controller;
  final ColorScheme colorScheme;

  const _RetryBanner({required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Couldn\'t refresh your plan. Showing the last known status.',
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: controller.isLoading ? null : controller.fetchSubscription,
            child: const Text('Retry'),
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

String _storeName(MySubscriptionModel sub) =>
    sub.provider == 'google' ? 'Google Play Store' : 'App Store';

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
