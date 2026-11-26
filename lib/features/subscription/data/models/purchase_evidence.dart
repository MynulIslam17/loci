import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Store platform a purchase came from, as the backend names it.
enum StorePlatform { apple, google }

/// Builds the `POST /subscriptions/verify` body for a store purchase (§2.2).
///
/// iOS: always `transactionId`; `signedTransactionJws` only when the evidence
/// really is a StoreKit 2 JWS — a legacy StoreKit 1 base64 receipt is not
/// accepted by the server.
/// Android: `purchaseToken` = `serverVerificationData`.
Map<String, dynamic> buildVerifyBody(
  PurchaseDetails purchase, {
  required StorePlatform platform,
}) {
  final String evidence = purchase.verificationData.serverVerificationData;
  if (platform == StorePlatform.apple) {
    return <String, dynamic>{
      'platform': 'apple',
      'productId': purchase.productID,
      'transactionId':
          appleTransactionId(purchase) ?? '',
      if (looksLikeJws(evidence)) 'signedTransactionJws': evidence,
    };
  }
  return <String, dynamic>{
    'platform': 'google',
    'productId': purchase.productID,
    'purchaseToken': evidence,
  };
}

/// The StoreKit transaction id. The plugin reports id `0` as a null
/// `purchaseID` (Xcode StoreKit testing numbers transactions from 0), so fall
/// back to the `transactionId` inside the signed transaction payload.
String? appleTransactionId(PurchaseDetails purchase) {
  final String? id = purchase.purchaseID;
  if (id != null && id.isNotEmpty) return id;
  return transactionIdFromJws(purchase.verificationData.serverVerificationData);
}

/// Reads `transactionId` from a JWS payload WITHOUT verifying it — only used
/// to address the transaction; the server verifies the signature.
String? transactionIdFromJws(String jws) {
  if (!looksLikeJws(jws)) return null;
  try {
    final Object? payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(jws.split('.')[1]))),
    );
    if (payload is! Map) return null;
    final Object? id = payload['transactionId'];
    return id?.toString();
  } catch (_) {
    return null;
  }
}

/// A compact JWS: base64url JSON header (`eyJ…`) and exactly 3 dot parts.
bool looksLikeJws(String value) =>
    value.startsWith('eyJ') && value.split('.').length == 3;

/// Stable identity of a verify body, used to dedupe queue entries.
/// Apple purchases are keyed by transaction id, Google by purchase token.
String verifyBodyKey(Map<String, dynamic> body) {
  final String platform = body['platform']?.toString() ?? '';
  final String evidence = platform == 'google'
      ? body['purchaseToken']?.toString() ?? ''
      : body['transactionId']?.toString() ?? '';
  return '$platform|${body['productId'] ?? ''}|$evidence';
}

/// True when a body carries enough evidence for the server to look it up.
bool hasVerifiableEvidence(Map<String, dynamic> body) {
  if (body['platform'] == 'google') {
    return (body['purchaseToken']?.toString() ?? '').isNotEmpty;
  }
  return (body['transactionId']?.toString() ?? '').isNotEmpty;
}
