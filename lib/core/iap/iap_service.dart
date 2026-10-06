import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_config.dart';
import 'iap_event.dart';
import 'iap_verifier.dart';

class IapService {
  IapService({
    required IapConfig config,
    required IapPurchaseVerifier verifyPurchase,
    required IapEntitlementHandler onEntitlementGranted,
    InAppPurchase? store,
  }) : _config = config,
       _verifyPurchase = verifyPurchase,
       _onEntitlementGranted = onEntitlementGranted,
       _store = store ?? InAppPurchase.instance;

  final IapConfig _config;
  final IapPurchaseVerifier _verifyPurchase;
  final IapEntitlementHandler _onEntitlementGranted;
  final InAppPurchase _store;

  final StreamController<IapEvent> _events =
      StreamController<IapEvent>.broadcast();
  final Map<String, ProductDetails> _products = <String, ProductDetails>{};
  final Set<String> _processingPurchases = <String>{};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Future<void>? _initialization;
  bool _initialized = false;
  bool _available = false;

  Stream<IapEvent> get events => _events.stream;
  bool get isInitialized => _initialized;
  bool get isAvailable => _available;
  List<ProductDetails> get products =>
      List<ProductDetails>.unmodifiable(_products.values);
  ProductDetails? productById(String productId) => _products[productId];
  Set<String> get missingProductIds =>
      _config.productIds.difference(_products.keys.toSet());

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (_initialized) return;

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
      final Object error = response.error!;
      _emit(
        IapEvent(
          type: IapEventType.error,
          message: response.error!.message,
          error: error,
        ),
      );
      throw StateError(response.error!.message);
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

  Future<bool> purchase(String productId) async {
    _ensureReady();

    final ProductDetails? product = _products[productId];
    if (product == null) {
      throw ArgumentError.value(
        productId,
        'productId',
        'Product was not loaded from the store.',
      );
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    if (_config.isConsumable(productId)) {
      return _store.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    }

    return _store.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    _ensureReady();
    _emit(const IapEvent(type: IapEventType.restoreStarted));

    try {
      await _store.restorePurchases();
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
          await _processVerifiedPurchase(purchase);
          break;
      }
    }
  }

  Future<void> _processVerifiedPurchase(PurchaseDetails purchase) async {
    if (!_config.productIds.contains(purchase.productID)) {
      await _completeIfNeeded(purchase);
      return;
    }
    final String key = _purchaseKey(purchase);
    if (!_processingPurchases.add(key)) return;

    try {
      final bool isValid = await _verifyPurchase(purchase);

      if (!isValid) {
        await _completeIfNeeded(purchase);
        _emit(
          IapEvent(
            type: IapEventType.verificationFailed,
            productId: purchase.productID,
            purchase: purchase,
            message: 'Purchase verification failed.',
          ),
        );
        return;
      }

      await _onEntitlementGranted(purchase);

      await _completeIfNeeded(purchase);

      _emit(
        IapEvent(
          type: purchase.status == PurchaseStatus.restored
              ? IapEventType.purchaseRestored
              : IapEventType.purchaseCompleted,
          productId: purchase.productID,
          purchase: purchase,
        ),
      );
    } catch (error) {
      _emit(
        IapEvent(
          type: IapEventType.error,
          productId: purchase.productID,
          purchase: purchase,
          message: 'Failed to process purchase.',
          error: error,
        ),
      );
    } finally {
      _processingPurchases.remove(key);
    }
  }

  Future<void> _completeIfNeeded(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }

  String _purchaseKey(PurchaseDetails purchase) {
    return [
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
    if (!_events.isClosed) _events.add(event);
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    await _events.close();
  }
}
