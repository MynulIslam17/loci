import 'package:loci/features/subscription/data/models/my_subscription_model.dart';

/// Server error codes the subscription flow matches on (never on messages).
abstract final class SubscriptionErrorCodes {
  static const String purchasePending = 'PURCHASE_PENDING';
  static const String invalidPurchase = 'INVALID_PURCHASE';
  static const String retryableStoreError = 'RETRYABLE_STORE_ERROR';
  static const String storeCancelRequired = 'STORE_CANCEL_REQUIRED';
  static const String subscriptionRequired = 'SUBSCRIPTION_REQUIRED';
  static const String insufficientSpotlightCredits =
      'INSUFFICIENT_SPOTLIGHT_CREDITS';
  static const String businessAccessDenied = 'BUSINESS_ACCESS_DENIED';
}

/// Outcome of `POST /subscriptions/verify`, mapped by HTTP status + `code`.
enum VerifyResultKind {
  /// 200 — verified, access granted. Finish the store transaction.
  success,

  /// 409 PURCHASE_PENDING — keep the transaction open, retry later.
  pending,

  /// 400/409 INVALID_PURCHASE — definitive rejection. Finish, don't retry.
  invalid,

  /// 503 RETRYABLE_STORE_ERROR, other 5xx, timeout, offline — keep open, retry.
  retryable,
}

class VerifyResult {
  const VerifyResult(this.kind, {this.message, this.subscription});

  final VerifyResultKind kind;
  final String? message;
  final MySubscriptionModel? subscription;

  bool get isDefinitive =>
      kind == VerifyResultKind.success || kind == VerifyResultKind.invalid;

  /// Maps an HTTP status + error `code` to a [VerifyResultKind] (spec §4.3).
  static VerifyResultKind classify(int status, String? code) {
    if (status >= 200 && status < 300) return VerifyResultKind.success;
    if (code == SubscriptionErrorCodes.purchasePending) {
      return VerifyResultKind.pending;
    }
    if (code == SubscriptionErrorCodes.invalidPurchase) {
      return VerifyResultKind.invalid;
    }
    return VerifyResultKind.retryable;
  }
}
