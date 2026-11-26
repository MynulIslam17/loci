import 'package:in_app_purchase/in_app_purchase.dart';

/// What the backend said about a purchase. Decides whether the store
/// transaction may be finished.
enum IapVerification {
  /// Verified — access granted. Finish the transaction.
  verified,

  /// Store payment not completed yet (Ask to Buy, slow card). Keep it open.
  pending,

  /// Definitively rejected. Finish it so it isn't re-delivered forever.
  rejected,

  /// Temporary failure (server/store/offline). Keep it open and retry.
  retryLater,
}

extension IapVerificationX on IapVerification {
  /// Only a definitive server answer may finish (iOS) the transaction.
  bool get shouldComplete =>
      this == IapVerification.verified || this == IapVerification.rejected;
}

/// Sends the purchase to the backend. Must not throw for expected outcomes;
/// a thrown error is treated as [IapVerification.retryLater].
typedef IapPurchaseVerifier =
    Future<IapVerificationResult> Function(PurchaseDetails purchase);

class IapVerificationResult {
  const IapVerificationResult(this.status, {this.message});

  final IapVerification status;

  /// User-facing server message (e.g. "linked to another Loci account").
  final String? message;
}
