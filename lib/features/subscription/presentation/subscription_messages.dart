import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Every message the subscription flow can show. Raw exceptions, StoreKit /
/// Play Billing strings and backend debug text never reach the screen — they
/// are logged with [logSubscriptionError] and replaced by one of these.
abstract final class SubscriptionMessages {
  static const String generic = 'Something went wrong. Please try again.';
  static const String offline =
      'You\'re offline. Check your connection and try again.';
  static const String plansUnavailable =
      'Subscription plans aren\'t available right now. Please try again later.';
  static const String storeUnavailable =
      'Subscriptions aren\'t available on this device right now.';
  static const String storeFailed =
      'The store couldn\'t complete the purchase. If you\'re already '
      'subscribed with this Apple ID or Google account, tap Restore Purchases.';
  static const String storeOffline =
      'Couldn\'t reach the store. Check your connection and try again.';
  static const String purchaseCancelled = 'Purchase cancelled.';
  static const String purchaseUnverified =
      'We couldn\'t confirm this purchase with the store. If you were '
      'charged, tap Restore Purchases or contact support.';
  static const String restoredInactive =
      'We found a previous purchase, but it\'s no longer active.';
  static const String restoreFailed =
      'Couldn\'t restore purchases. Please try again.';
  static const String statusUnavailable =
      'Couldn\'t load your subscription. Please try again.';
  static const String openStoreFailed =
      'Couldn\'t open subscription settings. You can manage it from your '
      'device\'s App Store or Play Store settings.';

  /// The store answered "you're already subscribed" with a purchase that the
  /// backend links to a different Loci account.
  static String storeAccountUsedElsewhere({required bool isIOS}) {
    final String account = isIOS ? 'Apple ID' : 'Google account';
    return 'This $account already has a Loci subscription on a different '
        'Loci account. Sign in to that Loci account, or subscribe with a '
        'different $account.';
  }

  static const String cancelFailed =
      'Couldn\'t cancel your subscription. Please try again.';
}

bool _isConnectivityError(Object error) {
  if (error is SocketException ||
      error is TimeoutException ||
      error is HttpException ||
      error is HandshakeException) {
    return true;
  }
  final String type = error.runtimeType.toString();
  return type == 'ClientException';
}

final RegExp _technical = RegExp(
  r'exception|error:|stack|trace|certificate|signed data|signature|\bjws\b|'
  r'\bjwt\b|\bx5c\b|\bnull\b|undefined|\bnan\b|[{}\[\]<>]|status ?code|'
  r'econn|enotfound|etimedout|socket|\bsql\b|mongo|prisma|cast to|'
  r'typeerror|referenceerror|syntaxerror|cannot read|is not a function|'
  r'internal server|\bat [\w.]+ ?\(|0x[0-9a-f]{4,}|https?://',
  caseSensitive: false,
);

/// True when [message] reads like something written for end users (e.g.
/// "This purchase belongs to another Loci account") rather than debug output
/// (e.g. "Invalid Apple signed data: certificate chain must contain…").
bool isUserFacingMessage(String? message) {
  final String text = message?.trim() ?? '';
  if (text.length < 3 || text.length > 200) return false;
  return !_technical.hasMatch(text);
}

/// [message] when it's safe to show, otherwise [fallback].
String userFacingOr(String? message, String fallback) =>
    isUserFacingMessage(message) ? message!.trim() : fallback;

/// Maps any error to user-facing copy. Never returns `error.toString()`.
String friendlySubscriptionError(
  Object? error, {
  String fallback = SubscriptionMessages.generic,
}) {
  if (error == null) return fallback;
  if (_isConnectivityError(error)) return SubscriptionMessages.offline;
  if (error is PlatformException || error is IAPError) {
    final String code =
        (error is PlatformException ? error.code : (error as IAPError).code)
            .toLowerCase();
    final String details =
        (error is PlatformException
                ? '${error.message} ${error.details}'
                : (error as IAPError).message)
            .toLowerCase();
    if (code.contains('cancel') || details.contains('cancel')) {
      return SubscriptionMessages.purchaseCancelled;
    }
    if (code.contains('network') ||
        details.contains('network') ||
        details.contains('offline') ||
        details.contains('internet')) {
      return SubscriptionMessages.storeOffline;
    }
    return SubscriptionMessages.storeFailed;
  }
  // `Exception('No internet connection')` from the network layer carries an
  // already-friendly message; programmer errors (StateError, TypeError…)
  // never do.
  if (error is Exception) {
    return userFacingOr(
      error.toString().replaceFirst(RegExp(r'^\w*Exception: '), ''),
      fallback,
    );
  }
  return fallback;
}

/// Technical details for developers only (debug/profile console).
void logSubscriptionError(String context, Object? error) {
  if (error == null) return;
  debugPrint('[subscription] $context: $error');
}
