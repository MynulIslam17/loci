import 'package:flutter/material.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';

/// Title + body for a subscription dialog. Pure so the copy is testable.
typedef DialogCopy = ({String title, String message});

/// "Switch to Yearly?" — shown before a subscriber starts a plan change.
/// The store decides whether the change is immediate or at renewal (it
/// depends on the subscription-group ranking), so the copy doesn't promise
/// either; it does promise no double charge, which the store guarantees.
DialogCopy switchConfirmCopy({
  required String currentPlan,
  required String? currentPrice,
  required String newPlan,
  required String? newPrice,
  required bool isIOS,
}) {
  final String store = isIOS ? 'The App Store' : 'Google Play';
  final String from = currentPrice == null
      ? 'You\'re on $currentPlan.'
      : 'You\'re on $currentPlan ($currentPrice).';
  final String to = newPrice == null
      ? 'Switch to $newPlan?'
      : '$newPlan is $newPrice.';
  return (
    title: 'Switch to $newPlan?',
    message:
        '$from $to\n\n$store decides when the change starts — right away or '
        'when your current plan renews — and adjusts the price for unused '
        'time. You won\'t be charged twice.',
  );
}

/// Copy for a purchase that didn't end in immediate success, or null when no
/// dialog is needed (success navigates away; a user cancel needs nothing).
DialogCopy? purchaseResultCopy(
  PurchaseOutcome outcome, {
  String? info,
  String? error,
}) {
  switch (outcome) {
    case PurchaseOutcome.success:
    case PurchaseOutcome.cancelled:
      return null;
    case PurchaseOutcome.scheduled:
      return (title: 'Switch scheduled', message: info ?? '');
    case PurchaseOutcome.pending:
      return (
        title: 'Purchase pending',
        message:
            info ??
            'Your payment is pending. We\'ll activate your plan as soon as '
                'it completes.',
      );
    case PurchaseOutcome.deferred:
      return (
        title: 'Almost done',
        message:
            info ??
            'Your payment went through. We\'ll finish activating your plan '
                'shortly — you don\'t need to buy again.',
      );
    case PurchaseOutcome.failed:
      if (error == null || error.isEmpty) return null;
      return (title: 'Purchase not completed', message: error);
  }
}

/// Copy for each Restore Purchases result.
DialogCopy restoreResultCopy(
  RestoreOutcome outcome, {
  String? info,
  String? error,
  required bool isIOS,
}) {
  final String account = isIOS ? 'Apple ID' : 'Google account';
  final String where = isIOS ? 'Settings › App Store' : 'the Play Store app';
  switch (outcome) {
    case RestoreOutcome.restored:
      return (
        title: 'Purchases restored',
        message: 'Your subscription is active on this account.',
      );
    case RestoreOutcome.nothing:
      return (
        title: 'No purchases found',
        message:
            'We couldn\'t find a Loci subscription for the $account signed '
            'in on this device. If you subscribed with a different $account, '
            'sign in with it in $where and try again.',
      );
    case RestoreOutcome.inactive:
      return (
        title: 'Subscription not active',
        message:
            error ??
            'We found a previous purchase, but it\'s no longer active.',
      );
    case RestoreOutcome.pending:
      return (
        title: 'Almost done',
        message:
            info ??
            'We found your purchase and will finish activating it shortly.',
      );
    case RestoreOutcome.failed:
      return (
        title: 'Couldn\'t restore purchases',
        message: error ?? 'Please try again.',
      );
  }
}

Future<void> showSubscriptionInfo(BuildContext context, DialogCopy copy) {
  if (!context.mounted) return Future<void>.value();
  return showInfoDialog(context, title: copy.title, message: copy.message);
}

Future<bool> confirmSubscriptionAction(
  BuildContext context,
  DialogCopy copy, {
  required String confirmText,
  String cancelText = 'Cancel',
  IconData icon = Icons.swap_horiz_rounded,
}) {
  if (!context.mounted) return Future<bool>.value(false);
  return showConfirmDialog(
    context,
    title: copy.title,
    message: copy.message,
    confirmText: confirmText,
    cancelText: cancelText,
    icon: icon,
  );
}
