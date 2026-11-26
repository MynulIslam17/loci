import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/features/subscription/data/models/purchase_evidence.dart';
import 'package:loci/features/subscription/data/models/verify_result.dart';
import 'package:loci/features/subscription/data/repositories/subscription_repository.dart';

import 'fakes.dart';

class FakeNetwork extends NetworkCaller {
  FakeNetwork() : super(onUnAuthorize: () {}, accessToken: () => 'token');
  Map<String, dynamic>? sent;
  String? lastUrl;
  NetworkResponse response = NetworkResponse(
    isSuccess: true,
    statusCode: 200,
    body: <String, dynamic>{'success': true, 'data': null},
  );

  @override
  Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    String? overrideToken,
    bool isRetry = false,
  }) async {
    sent = body;
    lastUrl = url;
    return response;
  }

  @override
  Future<NetworkResponse> getRequest({
    required String url,
    Map<String, dynamic>? queryParams,
    bool isRetry = false,
  }) async {
    lastUrl = url;
    return response;
  }
}

NetworkResponse failure(int status, {String? code, String message = 'msg'}) =>
    NetworkResponse(
      isSuccess: false,
      statusCode: status,
      errorCode: code,
      errorMessage: message,
      body: <String, dynamic>{
        'success': false,
        'message': message,
        'code': ?code,
      },
    );

void main() {
  group('VerifyResult.classify (spec §4.3)', () {
    test('maps status + code', () {
      expect(VerifyResult.classify(200, null), VerifyResultKind.success);
      expect(
        VerifyResult.classify(409, 'PURCHASE_PENDING'),
        VerifyResultKind.pending,
      );
      expect(
        VerifyResult.classify(400, 'INVALID_PURCHASE'),
        VerifyResultKind.invalid,
      );
      expect(
        VerifyResult.classify(409, 'INVALID_PURCHASE'),
        VerifyResultKind.invalid,
      );
      expect(
        VerifyResult.classify(503, 'RETRYABLE_STORE_ERROR'),
        VerifyResultKind.retryable,
      );
      expect(VerifyResult.classify(500, null), VerifyResultKind.retryable);
      expect(VerifyResult.classify(0, null), VerifyResultKind.retryable);
      expect(VerifyResult.classify(-1, null), VerifyResultKind.retryable);
      // A 400 without a code is not definitive.
      expect(VerifyResult.classify(400, null), VerifyResultKind.retryable);
    });
  });

  group('buildVerifyBody (spec §2.2)', () {
    test('apple sends transactionId and JWS only when it is a JWS', () {
      final PurchaseDetails jws = storePurchase(PurchaseStatus.purchased);
      expect(buildVerifyBody(jws, platform: StorePlatform.apple), <String, dynamic>{
        'platform': 'apple',
        'productId': 'ui.neatboutique.jacobi.business.monthly',
        'transactionId': '2000000812345678',
        'signedTransactionJws': 'eyJhbGciOiJFUzI1NiJ9.eyJ0eCI6MX0.c2ln',
      });
      final PurchaseDetails receipt = storePurchase(
        PurchaseStatus.purchased,
        evidence: 'MIIT1wYJKoZIhvcNAQcCoIIT...',
      );
      final Map<String, dynamic> body = buildVerifyBody(
        receipt,
        platform: StorePlatform.apple,
      );
      expect(body.containsKey('signedTransactionJws'), isFalse);
      expect(body['transactionId'], '2000000812345678');
    });

    test('google sends the purchase token', () {
      final PurchaseDetails p = storePurchase(
        PurchaseStatus.purchased,
        evidence: 'google-token',
      );
      expect(buildVerifyBody(p, platform: StorePlatform.google), <String, dynamic>{
        'platform': 'google',
        'productId': 'ui.neatboutique.jacobi.business.monthly',
        'purchaseToken': 'google-token',
      });
    });

    test('StoreKit id 0 (null purchaseID) falls back to the JWS transactionId', () {
      // header.{"transactionId":"0","productId":"m"}.sig — as Xcode StoreKit
      // testing issues for the first local transaction.
      const String jws = 'eyJhbGciOiJFUzI1NiJ9.'
          'eyJ0cmFuc2FjdGlvbklkIjoiMCIsInByb2R1Y3RJZCI6Im0ifQ.c2ln';
      final PurchaseDetails p = storePurchase(
        PurchaseStatus.purchased,
        purchaseId: null,
        evidence: jws,
      );
      final Map<String, dynamic> body = buildVerifyBody(p, platform: StorePlatform.apple);
      expect(body['transactionId'], '0');
      expect(body['signedTransactionJws'], jws);
      expect(hasVerifiableEvidence(body), isTrue);
      expect(transactionIdFromJws('not-a-jws'), isNull);
      expect(transactionIdFromJws('eyJ.%%%.x'), isNull);
    });

    test('looksLikeJws', () {
      expect(looksLikeJws('eyJa.b.c'), isTrue);
      expect(looksLikeJws('eyJa.b'), isFalse);
      expect(looksLikeJws('abc.d.e'), isFalse);
    });

    test('evidence checks', () {
      expect(
        hasVerifiableEvidence(<String, dynamic>{'platform': 'apple', 'transactionId': ''}),
        isFalse,
      );
      expect(
        hasVerifiableEvidence(<String, dynamic>{'platform': 'google', 'purchaseToken': 't'}),
        isTrue,
      );
    });
  });

  group('SubscriptionRepository.verify', () {
    late FakeNetwork network;
    late SubscriptionRepository repo;
    final Map<String, dynamic> body = <String, dynamic>{
      'platform': 'apple',
      'productId': 'p',
      'transactionId': '1',
    };

    setUp(() {
      network = FakeNetwork();
      repo = SubscriptionRepository(network);
    });

    test('200 → success with the subscription', () async {
      network.response = NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'status': 'active',
            'credits': <String, dynamic>{'total': 100, 'used': 0, 'remaining': 100},
          },
        },
      );
      final VerifyResult r = await repo.verify(body);
      expect(network.sent, body);
      expect(network.lastUrl, endsWith('/subscriptions/verify'));
      expect(r.kind, VerifyResultKind.success);
      expect(r.subscription?.remainingCredits, 100);
    });

    test('codes map to kinds and keep the server message', () async {
      network.response = failure(409, code: 'INVALID_PURCHASE', message: 'This purchase is linked to another Loci account');
      VerifyResult r = await repo.verify(body);
      expect(r.kind, VerifyResultKind.invalid);
      expect(r.message, 'This purchase is linked to another Loci account');

      network.response = failure(409, code: 'PURCHASE_PENDING');
      expect((await repo.verify(body)).kind, VerifyResultKind.pending);

      network.response = failure(503, code: 'RETRYABLE_STORE_ERROR');
      expect((await repo.verify(body)).kind, VerifyResultKind.retryable);

      network.response = NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: 'timeout');
      r = await repo.verify(body);
      expect(r.kind, VerifyResultKind.retryable);
      expect(r.message, 'timeout');
    });

    test('account token is read from data.appAccountToken', () async {
      network.response = NetworkResponse(
        isSuccess: true,
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{'appAccountToken': 'uuid-1'},
        },
      );
      expect(await repo.getAccountToken(), 'uuid-1');
      expect(network.lastUrl, endsWith('/subscriptions/account-token'));
      network.response = failure(500);
      expect(repo.getAccountToken(), throwsException);
    });
  });
}
