import 'package:in_app_purchase/in_app_purchase.dart';

enum IapEventType {
  storeAvailable,
  storeUnavailable,
  productsLoaded,

  /// Store reports the payment as pending (never unlock).
  purchasePending,

  /// Backend verified a new purchase (200).
  purchaseCompleted,

  /// Backend verified a restored purchase (200).
  purchaseRestored,
  purchaseCanceled,
  purchaseFailed,

  /// Backend definitively rejected the purchase (INVALID_PURCHASE).
  verificationFailed,

  /// Backend says the store payment is still pending (PURCHASE_PENDING).
  verificationPending,

  /// Temporary failure — will retry; the transaction stays open.
  verificationDeferred,
  restoreStarted,
  restoreFinished,
  error,
}

class IapEvent {
  const IapEvent({
    required this.type,
    this.productId,
    this.purchase,
    this.products = const <ProductDetails>[],
    this.message,
    this.error,
  });

  final IapEventType type;
  final String? productId;
  final PurchaseDetails? purchase;
  final List<ProductDetails> products;
  final String? message;
  final Object? error;
}
