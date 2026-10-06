import 'package:in_app_purchase/in_app_purchase.dart';

enum IapEventType {
  storeAvailable,
  storeUnavailable,
  productsLoaded,
  purchasePending,
  purchaseCompleted,
  purchaseRestored,
  purchaseCanceled,
  purchaseFailed,
  verificationFailed,
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
