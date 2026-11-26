import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart'
    show ReplacementMode;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'iap_config.dart';
import 'iap_event.dart';
import 'iap_verifier.dart';

/// Loads the user's current Google Play subscription purchases (for plan
/// switches). Returns an empty list on iOS / when unavailable.
typedef GooglePastPurchasesLoader =
    Future<List<GooglePlayPurchaseDetails>> Function();

/// Finishes a transaction the plugin can't address (StoreKit 2 transaction
/// id 0 arrives with a null `purchaseID`, and the plugin's `completePurchase`
/// would throw). Returns false when it can't finish it either.
typedef IapTransactionFinisher =
    Future<bool> Function(PurchaseDetails purchase);

/// Thin wrapper around [InAppPurchase] that owns the purchase stream and
/// enforces "verify, then complete — never the other way round".
class IapService {
  IapService({
    required IapConfig config,
    required IapPurchaseVerifier verifyPurchase,
    InAppPurchase? store,
    bool? isAndroid,
    GooglePastPurchasesLoader? googlePastPurchases,
    IapTransactionFinisher? finishWithoutPurchaseId,
  }) : _config = config,
       _finishWithoutPurchaseId = finishWithoutPurchaseId,
       _verifyPurchase = verifyPurchase,
       _store = store ?? InAppPurchase.instance,
       _isAndroid = isAndroid ?? false,
       _googlePastPurchases = googlePastPurchases;

  final IapConfig _config;
  final IapPurchaseVerifier _verifyPurchase;
  final InAppPurchase _store;
  final bool _isAndroid;
  final GooglePastPurchasesLoader? _googlePastPurchases;
  final IapTransactionFinisher? _finishWithoutPurchaseId;

  final StreamController<IapEvent> _events =
      StreamController<IapEvent>.broadcast();
  final Map<String, ProductDetails> _products = <String, ProductDetails>{};
  final Set<String> _processingPurchases = <String>{};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Future<void>? _initialization;
  bool _initialized = false;
  bool _available = false;
  bool _disposed = false;

  Stream<IapEvent> get events => _events.stream;
  bool get isInitialized => _initialized;
  bool get isAvailable => _available;
  List<ProductDetails> get products =>
      List<ProductDetails>.unmodifiable(_products.values);
  ProductDetails? productById(String productId) => _products[productId];
  Set<String> get missingProductIds =>
      _config.productIds.difference(_products.keys.toSet());

  /// Subscribes to the purchase stream immediately (purchases completed while
  /// no paywall is open must not be lost), then loads products.
  Future<void> initialize() => _initialization ??= _initialize();

  void _listen() {
    _purchaseSubscription ??= _store.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _emit(
          IapEvent(
            type: IapEventType.error,
            message: 'Purchase stream error',
            error: error,
          ),
        );
      },
    );
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _listen();

    try {
      _available = await _store.isAvailable();

      if (!_available) {
        _emit(
          const IapEvent(
            type: IapEventType.storeUnavailable,
            message: 'In-app purchases are not available.',
          ),
        );
        _initialization = null;
        return;
      }

      _emit(const IapEvent(type: IapEventType.storeAvailable));
      await reloadProducts();
      _initialized = true;
    } catch (error) {
      _emit(
        IapEvent(
          type: IapEventType.error,
          message: 'Failed to initialize in-app purchases.',
          error: error,
        ),
      );
      _initialization = null;
      rethrow;
    }
  }

  Future<List<ProductDetails>> reloadProducts() async {
    if (!_available) return const <ProductDetails>[];

    final ProductDetailsResponse response = await _store.queryProductDetails(
      _config.productIds,
    );

    if (response.error != null) {
      final IAPError error = response.error!;
      _emit(
        IapEvent(
          type: IapEventType.error,
          message: error.message,
          error: error,
        ),
      );
      throw StateError(error.message);
    }

    _products
      ..clear()
      ..addEntries(
        response.productDetails.map(
          (ProductDetails product) => MapEntry(product.id, product),
        ),
      );

    _emit(
      IapEvent(
        type: IapEventType.productsLoaded,
        products: products,
        message: response.notFoundIDs.isEmpty
            ? null
            : 'Products not found: ${response.notFoundIDs.join(', ')}',
      ),
    );

    return products;
  }

  /// Starts a purchase. [applicationUserName] is the backend account token
  /// (iOS `appAccountToken`, Android `obfuscatedAccountId`).
  Future<bool> purchase(String productId, {String? applicationUserName}) async {
    _ensureReady();

    final ProductDetails? product = _products[productId];
    if (product == null) {
      throw ArgumentError.value(
        productId,
        'productId',
        'Product was not loaded from the store.',
      );
    }

    final PurchaseParam purchaseParam = await _purchaseParam(
      product,
      applicationUserName,
    );

    if (_config.isConsumable(productId)) {
      return _store.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    }

    return _store.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Android monthly ↔ yearly: pass the current purchase so Play replaces it
  /// instead of creating a second subscription. iOS handles this itself
  /// (both products are in one subscription group).
  Future<PurchaseParam> _purchaseParam(
    ProductDetails product,
    String? applicationUserName,
  ) async {
    if (!_isAndroid) {
      return PurchaseParam(
        productDetails: product,
        applicationUserName: applicationUserName,
      );
    }

    GooglePlayPurchaseDetails? oldPurchase;
    try {
      final List<GooglePlayPurchaseDetails> owned =
          await (_googlePastPurchases?.call() ??
              Future<List<GooglePlayPurchaseDetails>>.value(
                const <GooglePlayPurchaseDetails>[],
              ));
      for (final GooglePlayPurchaseDetails p in owned) {
        if (p.productID != product.id &&
            _config.productIds.contains(p.productID) &&
            p.status != PurchaseStatus.error &&
            p.status != PurchaseStatus.canceled) {
          oldPurchase = p;
          break;
        }
      }
    } catch (_) {
      // Fall back to a plain purchase; the server still keeps one
      // subscription per owner.
    }

    return GooglePlayPurchaseParam(
      productDetails: product,
      applicationUserName: applicationUserName,
      changeSubscriptionParam: oldPurchase == null
          ? null
          : ChangeSubscriptionParam(
              oldPurchaseDetails: oldPurchase,
              replacementMode: ReplacementMode.withTimeProration,
            ),
    );
  }

  Future<void> restorePurchases({String? applicationUserName}) async {
    _ensureReady();
    _emit(const IapEvent(type: IapEventType.restoreStarted));

    try {
      await _store.restorePurchases(applicationUserName: applicationUserName);
      _emit(const IapEvent(type: IapEventType.restoreFinished));
    } catch (error) {
      _emit(
        IapEvent(
          type: IapEventType.error,
          message: 'Failed to restore purchases.',
          error: error,
        ),
      );
      rethrow;
    }
  }

  /// Feeds transactions recovered outside the purchase stream (e.g. StoreKit 2
  /// `Transaction.unfinished` at launch) through the same verify → complete
  /// pipeline.
  Future<void> handleRecoveredPurchases(List<PurchaseDetails> purchases) =>
      _handlePurchaseUpdates(purchases);

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _emit(
            IapEvent(
              type: IapEventType.purchasePending,
              productId: purchase.productID,
              purchase: purchase,
            ),
          );
          break;

        case PurchaseStatus.error:
          _emit(
            IapEvent(
              type: IapEventType.purchaseFailed,
              productId: purchase.productID,
              purchase: purchase,
              message: purchase.error?.message,
              error: purchase.error,
            ),
          );
          await _completeIfNeeded(purchase);
          break;

        case PurchaseStatus.canceled:
          _emit(
            IapEvent(
              type: IapEventType.purchaseCanceled,
              productId: purchase.productID,
              purchase: purchase,
            ),
          );
          await _completeIfNeeded(purchase);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _processPurchase(purchase);
          break;
      }
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchase) async {
    if (!_config.productIds.contains(purchase.productID)) {
      // Not ours — finish it so the queue doesn't block.
      await _completeIfNeeded(purchase);
      return;
    }
    final String key = _purchaseKey(purchase);
    if (!_processingPurchases.add(key)) return;

    _emit(
      IapEvent(
        type: IapEventType.verificationStarted,
        productId: purchase.productID,
        purchase: purchase,
      ),
    );
    try {
      IapVerificationResult result;
      try {
        result = await _verifyPurchase(purchase);
      } catch (error) {
        result = IapVerificationResult(
          IapVerification.retryLater,
          message: error.toString(),
        );
      }

      // Verify first; finish ONLY on a definitive server answer. On pending /
      // retryable the transaction stays open so the store re-delivers it.
      if (result.status.shouldComplete) {
        try {
          await _completeIfNeeded(purchase);
        } catch (error) {
          // Server already has it; a failed finish is retried by the store.
          _emit(
            IapEvent(
              type: IapEventType.error,
              productId: purchase.productID,
              purchase: purchase,
              message: 'Failed to finish the store transaction.',
              error: error,
            ),
          );
        }
      }

      _emit(
        IapEvent(
          type: _eventTypeFor(result.status, purchase.status),
          productId: purchase.productID,
          purchase: purchase,
          message: result.message,
        ),
      );
    } finally {
      _processingPurchases.remove(key);
    }
  }

  static IapEventType _eventTypeFor(
    IapVerification verification,
    PurchaseStatus status,
  ) {
    switch (verification) {
      case IapVerification.verified:
        return status == PurchaseStatus.restored
            ? IapEventType.purchaseRestored
            : IapEventType.purchaseCompleted;
      case IapVerification.pending:
        return IapEventType.verificationPending;
      case IapVerification.rejected:
        return IapEventType.verificationFailed;
      case IapVerification.retryLater:
        return IapEventType.verificationDeferred;
    }
  }

  Future<void> _completeIfNeeded(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    final String? id = purchase.purchaseID;
    final IapTransactionFinisher? fallback = _finishWithoutPurchaseId;
    if ((id == null || id.isEmpty) && fallback != null) {
      if (await fallback(purchase)) return;
    }
    await _store.completePurchase(purchase);
  }

  String _purchaseKey(PurchaseDetails purchase) {
    return <String>[
      purchase.productID,
      purchase.purchaseID ?? '',
      purchase.transactionDate ?? '',
    ].join('|');
  }

  void _ensureReady() {
    if (!_initialized) {
      throw StateError('IapService.initialize() must be called first.');
    }
    if (!_available) {
      throw StateError('In-app purchases are not available.');
    }
  }

  void _emit(IapEvent event) {
    if (!_disposed && !_events.isClosed) _events.add(event);
  }

  Future<void> dispose() async {
    _disposed = true;
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    await _events.close();
  }
}
