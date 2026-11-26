import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/models/verify_result.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/routes/app_routes.dart';

/// Global paywall / credits sheet shown when the backend rejects a paid
/// action (spec §8). Routed primarily by the structured error `code` from
/// [NetworkCaller.onErrorCode] — one place, every feature. The message-text
/// match via [SnackbarService.errorInterceptor] remains as a migration
/// fallback and to swallow the duplicate snackbar.
class UpgradeRequiredSheet {
  UpgradeRequiredSheet._();

  static bool _isShowing = false;

  /// When a code-routed sheet was last opened, so the follow-up snackbar for
  /// the same failure is swallowed instead of opening a second sheet.
  static DateTime _lastCodeHandledAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Messages of recent non-paywall 403s (e.g. BUSINESS_ACCESS_DENIED) — the
  /// text fallback must never turn those into a paywall.
  static final Map<String, DateTime> _recentPlainErrors = <String, DateTime>{};

  static const Duration _dedupeWindow = Duration(seconds: 3);

  /// Words that mark a message as a plan-entitlement rejection rather than a
  /// generic failure. Deliberately conservative: a bare "You don't have
  /// permission…" (any 403) must NOT open the paywall.
  static final RegExp _entitlementPattern = RegExp(
    r'subscription|upgrade|\bplan\b|\bplans\b|limit reached|reached your|'
    r'active event|credits? (left|remaining|required)|insufficient.*credit|'
    r'hero spotlight',
    caseSensitive: false,
  );

  /// Which sheet (if any) a server error code maps to.
  static UpgradeSheetKind? kindForCode(String? code) {
    switch (code) {
      case SubscriptionErrorCodes.subscriptionRequired:
        return UpgradeSheetKind.paywall;
      case SubscriptionErrorCodes.insufficientSpotlightCredits:
        return UpgradeSheetKind.credits;
      default:
        return null;
    }
  }

  /// [NetworkCaller.onErrorCode] hook.
  static void handleErrorCode(int statusCode, String code, String message) {
    final UpgradeSheetKind? kind = kindForCode(code);
    if (kind == null) {
      if (code == SubscriptionErrorCodes.businessAccessDenied) {
        _recentPlainErrors[message] = DateTime.now();
      }
      return;
    }
    _lastCodeHandledAt = DateTime.now();
    if (kind == UpgradeSheetKind.credits) {
      unawaited(showCredits());
    } else {
      unawaited(show(message));
    }
  }

  /// [SnackbarService.errorInterceptor] hook. Returns true when the message
  /// is an entitlement rejection (the sheet is shown, the snackbar skipped).
  static bool maybeIntercept(String message) {
    final DateTime now = DateTime.now();
    _recentPlainErrors.removeWhere(
      (_, DateTime at) => now.difference(at) > _dedupeWindow,
    );
    if (_recentPlainErrors.containsKey(message)) return false;
    if (!_entitlementPattern.hasMatch(message)) return false;
    // Already routed by code moments ago → just swallow the snackbar.
    if (now.difference(_lastCodeHandledAt) < _dedupeWindow) return true;
    unawaited(show(message));
    return true;
  }

  static Future<void> show(String message) =>
      _present(_UpgradeSheetBody(message: message));

  /// "You need 10 credits, you have N. Credits reset on …"
  static Future<void> showCredits() async {
    if (_isShowing || Get.currentRoute == AppRoutes.subscription) return;
    MySubscriptionModel? sub;
    if (Get.isRegistered<SubscriptionStatusController>()) {
      final SubscriptionStatusController status =
          Get.find<SubscriptionStatusController>();
      // The charge just failed — refresh so the balance shown is current.
      try {
        await status.reload().timeout(const Duration(seconds: 4));
      } catch (_) {}
      sub = status.subscription.value;
    }
    await _present(
      _UpgradeSheetBody(
        title: 'Not enough Spotlight credits',
        message: creditsMessage(sub),
        icon: Icons.bolt_rounded,
        primaryLabel: 'View my plan',
        primaryRoute: AppRoutes.mySubscription,
      ),
    );
  }

  /// Copy for the credits sheet. Pure for testing.
  static String creditsMessage(MySubscriptionModel? sub, {DateFormat? format}) {
    const int cost = SubscriptionStatusController.spotlightCost;
    final String base = sub == null
        ? 'Each Spotlight ad costs $cost credits.'
        : 'You need $cost credits, you have ${sub.remainingCredits}.';
    final DateTime? resetAt = DateTime.tryParse(sub?.creditsExpireAt ?? '');
    if (resetAt == null) return base;
    final String date = (format ?? DateFormat('MMM d, yyyy')).format(
      resetAt.toLocal(),
    );
    return '$base Credits reset on $date.';
  }

  static Future<void> _present(Widget body) async {
    // One sheet at a time, and pointless while the user is already on the
    // plans page.
    if (_isShowing || Get.currentRoute == AppRoutes.subscription) return;
    _isShowing = true;
    try {
      await Get.bottomSheet(
        body,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    } finally {
      _isShowing = false;
    }
  }
}

enum UpgradeSheetKind { paywall, credits }

class _UpgradeSheetBody extends StatelessWidget {
  final String message;
  final String title;
  final IconData icon;
  final String primaryLabel;
  final String primaryRoute;

  const _UpgradeSheetBody({
    required this.message,
    this.title = 'Upgrade to unlock this',
    this.icon = Icons.workspace_premium_rounded,
    this.primaryLabel = 'View plans',
    this.primaryRoute = AppRoutes.subscription,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        16 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Premium mark
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.2),
                  colorScheme.primary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.textLg(
              color: colorScheme.onSurface,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          // The backend's own explanation of what the plan doesn't cover.
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Get.back(); // close the sheet first
                Get.toNamed(primaryRoute);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    primaryLabel,
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
          const SizedBox(height: 8),
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Maybe later',
              style: AppTextStyle.textSm(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
