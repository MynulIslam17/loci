import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/routes/app_routes.dart';

/// Global paywall shown when the backend rejects an action because the
/// caller's plan doesn't include it (create event/route/raffle, credit limits,
/// etc.). Wired into [SnackbarService.errorInterceptor] at app start, so any
/// controller that funnels its error through SnackbarService gets this sheet
/// instead of a raw red snackbar — no per-feature handling needed.
class UpgradeRequiredSheet {
  UpgradeRequiredSheet._();

  static bool _isShowing = false;

  /// Words that mark a message as a plan-entitlement rejection rather than a
  /// generic failure. Deliberately conservative: a bare "You don't have
  /// permission…" (any 403) must NOT open the paywall.
  static final RegExp _entitlementPattern = RegExp(
    r'subscription|upgrade|\bplan\b|\bplans\b|limit reached|reached your|'
    r'active event|credits? (left|remaining|required)',
    caseSensitive: false,
  );

  /// [SnackbarService.errorInterceptor] hook. Returns true when the message is
  /// an entitlement rejection and the paywall was shown (so the caller skips
  /// its snackbar).
  static bool maybeIntercept(String message) {
    if (!_entitlementPattern.hasMatch(message)) return false;
    show(message);
    return true;
  }

  static Future<void> show(String message) async {
    // One sheet at a time, and pointless while the user is already on the
    // plans page.
    if (_isShowing || Get.currentRoute == AppRoutes.subscription) return;
    _isShowing = true;
    try {
      await Get.bottomSheet(
        _UpgradeSheetBody(message: message),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    } finally {
      _isShowing = false;
    }
  }
}

class _UpgradeSheetBody extends StatelessWidget {
  final String message;

  const _UpgradeSheetBody({required this.message});

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
              Icons.workspace_premium_rounded,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Upgrade to unlock this',
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
                Get.toNamed(AppRoutes.subscription);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View plans',
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
