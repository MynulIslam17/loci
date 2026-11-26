import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/models/verify_result.dart';
import 'package:loci/features/subscription/data/repositories/subscription_repository.dart';
import 'package:loci/features/subscription/data/storage/pending_verification_queue.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

class MemoryQueueStore implements QueueStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

/// Store fake: tests push purchase updates through [updates].
class FakeStore implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> updates =
      StreamController<List<PurchaseDetails>>.broadcast();
  final List<PurchaseDetails> completed = <PurchaseDetails>[];
  final List<PurchaseParam> bought = <PurchaseParam>[];
  final List<String?> restoredWith = <String?>[];
  bool available = true;

  /// Purchases emitted when [restorePurchases] is called.
  List<PurchaseDetails> restoreResult = <PurchaseDetails>[];

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(
        productDetails: ids.map(product).toList(),
        notFoundIDs: const <String>[],
      );

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase);
    purchase.pendingCompletePurchase = false;
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    bought.add(purchaseParam);
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoredWith.add(applicationUserName);
    if (restoreResult.isNotEmpty) updates.add(restoreResult);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProductDetails product(String id) => ProductDetails(
  id: id,
  title: id,
  description: id,
  price: id == LociIapProducts.yearly ? '\$290.00' : '\$29.00',
  rawPrice: id == LociIapProducts.yearly ? 290 : 29,
  currencyCode: 'USD',
);

PurchaseDetails storePurchase(
  PurchaseStatus status, {
  String productId = LociIapProducts.monthly,
  String? purchaseId = '2000000812345678',
  String evidence = 'eyJhbGciOiJFUzI1NiJ9.eyJ0eCI6MX0.c2ln',
}) {
  final PurchaseDetails p = PurchaseDetails(
    productID: productId,
    purchaseID: purchaseId,
    transactionDate: '1700000000000',
    status: status,
    verificationData: PurchaseVerificationData(
      localVerificationData: '',
      serverVerificationData: evidence,
      source: 'app_store',
    ),
  );
  p.pendingCompletePurchase = status != PurchaseStatus.pending;
  return p;
}

MySubscriptionModel activeSubscription({int remaining = 100}) =>
    MySubscriptionModel.fromJson(<String, dynamic>{
      'status': 'active',
      'planId': 'monthly',
      'planName': 'Monthly',
      'billingType': 'monthly',
      'provider': 'apple',
      'cancelAtPeriodEnd': false,
      'credits': <String, dynamic>{
        'total': 100,
        'used': 100 - remaining,
        'remaining': remaining,
      },
    });

/// Service fake: scripted verify results, records calls.
class FakeSubscriptionService extends SubscriptionService {
  FakeSubscriptionService()
    : super(
        SubscriptionRepository(
          NetworkCaller(onUnAuthorize: () {}, accessToken: () => ''),
        ),
      );

  final List<Map<String, dynamic>> verified = <Map<String, dynamic>>[];
  final List<VerifyResult> verifyResults = <VerifyResult>[];
  VerifyResult defaultVerify = const VerifyResult(VerifyResultKind.success);
  String accountToken = '6f1c3a8e-2b4d-4c1e-9a7f-0e5d2c8b1a34';
  bool tokenFails = false;
  int tokenCalls = 0;

  Object? subscriptionError;
  MySubscriptionModel? subscriptionResult;
  int statusCalls = 0;
  List<String> businessIds = <String>['biz-1'];

  @override
  Future<String> getAccountToken(String userId) async {
    tokenCalls++;
    if (tokenFails) throw Exception('offline');
    return accountToken;
  }

  @override
  Future<VerifyResult> verifyPurchase(Map<String, dynamic> body) async {
    verified.add(Map<String, dynamic>.from(body));
    if (verifyResults.isNotEmpty) return verifyResults.removeAt(0);
    return defaultVerify;
  }

  @override
  Future<MySubscriptionModel?> getMySubscription(String businessId) async {
    statusCalls++;
    final Object? error = subscriptionError;
    if (error != null) throw error;
    return subscriptionResult;
  }

  @override
  Future<List<BusinessModel>> getMyBusinesses() async => businessIds
      .map((String id) => BusinessModel.fromJson(<String, dynamic>{'_id': id, 'id': id, 'name': id}))
      .toList();
}
