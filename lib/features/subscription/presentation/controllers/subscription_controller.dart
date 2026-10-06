import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:loci/core/iap/iap.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';

class SubscriptionController extends GetxController {
  late final IapService _iapService;
  StreamSubscription<IapEvent>? _iapEvents;
  Completer<bool>? _purchaseResult;
  String? _pendingProductId;

  final Rxn<ProductDetails> monthlyProduct = Rxn<ProductDetails>();
  final Rxn<ProductDetails> yearlyProduct = Rxn<ProductDetails>();
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxnString errorMessage = RxnString();
  // Local transaction feedback only; account entitlement is backend-owned.
  final RxnString lastProcessedPlan = RxnString();
  final RxList<StoreSubscriptionPlan> plans = <StoreSubscriptionPlan>[].obs;
  final Rxn<StoreSubscriptionPlan> selectedPlan = Rxn<StoreSubscriptionPlan>();

  ProductDetails? productFor(String? productId) =>
      productId == LociIapProducts.monthly
      ? monthlyProduct.value
      : productId == LociIapProducts.yearly
      ? yearlyProduct.value
      : null;

  @override
  void onInit() {
    super.onInit();
    plans.assignAll(StoreSubscriptionPlan.catalog);
    selectedPlan.value = plans.firstWhere(
      (StoreSubscriptionPlan plan) => plan.type == StorePlanType.monthly,
    );
    _iapService = IapService(
      config: const IapConfig(productIds: LociIapProducts.all),
      // TestFlight only. Replace with server verification before release.
      verifyPurchase: (PurchaseDetails purchase) async => true,
      onEntitlementGranted: (PurchaseDetails purchase) async {
        if (purchase.productID == LociIapProducts.monthly) {
          lastProcessedPlan.value = 'monthly';
        } else if (purchase.productID == LociIapProducts.yearly) {
          lastProcessedPlan.value = 'yearly';
        }
      },
    );
    _iapEvents = _iapService.events.listen(_handleEvent);
    initialize();
  }

  void selectPlan(StoreSubscriptionPlan plan) => selectedPlan.value = plan;

  Future<bool> subscribe() async {
    final StoreSubscriptionPlan? plan = selectedPlan.value;
    if (plan == null) return false;
    if (!plan.isPaid) return false;
    return purchase(plan.productId!);
  }

  Future<void> initialize() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await _iapService.initialize();
      if (!_iapService.isAvailable) {
        errorMessage.value = 'In-app purchases are not available.';
      }
      _updateProducts();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateProducts() {
    monthlyProduct.value = _iapService.productById(LociIapProducts.monthly);
    yearlyProduct.value = _iapService.productById(LociIapProducts.yearly);
  }

  void _handleEvent(IapEvent event) {
    switch (event.type) {
      case IapEventType.productsLoaded:
        _updateProducts();
        isLoading.value = false;
        errorMessage.value = event.message;
      case IapEventType.purchasePending:
        if (event.productId == _pendingProductId) isPurchasing.value = true;
      case IapEventType.purchaseCompleted:
      case IapEventType.purchaseRestored:
        _finishPurchase(true, productId: event.productId);
      case IapEventType.purchaseCanceled:
        _finishPurchase(false, productId: event.productId);
      case IapEventType.purchaseFailed:
        if (event.productId == _pendingProductId) {
          errorMessage.value = event.message ?? 'Purchase failed.';
        }
        _finishPurchase(false, productId: event.productId);
      case IapEventType.verificationFailed:
      case IapEventType.error:
        if (event.productId == null || event.productId == _pendingProductId) {
          errorMessage.value = event.message ?? 'Something went wrong.';
        }
        _finishPurchase(false, productId: event.productId);
      case IapEventType.storeUnavailable:
        errorMessage.value = event.message;
      default:
        break;
    }
  }

  Future<bool> purchase(String productId) async {
    if (isPurchasing.value || productFor(productId) == null) return false;
    try {
      errorMessage.value = null;
      isPurchasing.value = true;
      final Completer<bool> result = Completer<bool>();
      _purchaseResult = result;
      _pendingProductId = productId;
      final bool started = await _iapService.purchase(productId);
      if (!started) _finishPurchase(false);
      return await result.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          isPurchasing.value = false;
          _purchaseResult = null;
          _pendingProductId = null;
          errorMessage.value =
              'Purchase is still pending. Check your store account.';
          return false;
        },
      );
    } catch (error) {
      isPurchasing.value = false;
      _finishPurchase(false);
      errorMessage.value = error.toString();
      return false;
    }
  }

  void _finishPurchase(bool successful, {String? productId}) {
    if (productId != null && productId != _pendingProductId) return;
    final Completer<bool>? result = _purchaseResult;
    _purchaseResult = null;
    _pendingProductId = null;
    isPurchasing.value = false;
    if (result != null && !result.isCompleted) result.complete(successful);
  }

  Future<void> restorePurchases() async {
    try {
      errorMessage.value = null;
      await _iapService.restorePurchases();
    } catch (error) {
      errorMessage.value = error.toString();
    }
  }

  @override
  void onClose() {
    _iapEvents?.cancel();
    _iapService.dispose();
    super.onClose();
  }
}
