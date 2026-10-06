import 'package:in_app_purchase/in_app_purchase.dart';

typedef IapPurchaseVerifier = Future<bool> Function(
  PurchaseDetails purchase,
);

typedef IapEntitlementHandler = Future<void> Function(
  PurchaseDetails purchase,
);
