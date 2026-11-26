import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';
import 'package:loci/features/subscription/data/models/purchase_evidence.dart';
import 'package:loci/features/subscription/data/models/verify_result.dart';
import 'package:loci/features/subscription/data/storage/pending_verification_queue.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeStore store;
  late FakeSubscriptionService service;
  late MemoryQueueStore queueStore;
  late PendingVerificationQueue queue;
  late String? userId;
  late int statusRefreshes;
  late StreamController<Object?> session;
  late StreamController<bool> connectivity;

  List<PurchaseDetails> unfinished = <PurchaseDetails>[];

  SubscriptionController build({StorePlatform platform = StorePlatform.apple}) {
    final SubscriptionController c = SubscriptionController(
      unfinishedTransactions: () async => unfinished,
      service: service,
      queue: queue,
      store: store,
      platform: platform,
      currentUserId: () => userId,
      refreshStatus: () async => statusRefreshes++,
      sessionChanges: session.stream,
      connectivityRestored: connectivity.stream,
      observeLifecycle: false,
      purchaseTimeout: const Duration(milliseconds: 300),
      restoreQuietPeriod: const Duration(milliseconds: 20),
    );
    Get.put<SubscriptionController>(c);
    return c;
  }

  setUp(() {
    Get.testMode = true;
    store = FakeStore();
    service = FakeSubscriptionService();
    queueStore = MemoryQueueStore();
    queue = PendingVerificationQueue(store: queueStore);
    userId = 'userA';
    statusRefreshes = 0;
    session = StreamController<Object?>.broadcast();
    connectivity = StreamController<bool>.broadcast();
    unfinished = <PurchaseDetails>[];
  });

  tearDown(() async {
    Get.reset();
    await session.close();
    await connectivity.close();
  });

  /// Starts a purchase and delivers [delivered] from the store.
  Future<PurchaseOutcome> buy(
    SubscriptionController c,
    List<PurchaseStatus> delivered,
  ) async {
    final Future<PurchaseOutcome> outcome = c.purchase(LociIapProducts.monthly);
    await pumpEventQueue();
    for (final PurchaseStatus s in delivered) {
      store.updates.add(<PurchaseDetails>[storePurchase(s)]);
      await pumpEventQueue();
    }
    return outcome;
  }

  test('loads store prices from ProductDetails', () async {
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(c.isLoading.value, isFalse);
    expect(c.productFor(LociIapProducts.monthly)?.price, '\$29.00');
    expect(c.productFor(LociIapProducts.yearly)?.price, '\$290.00');
  });

  test('success: token attached, verified, completed, status refreshed, queue empty', () async {
    final SubscriptionController c = build();
    await pumpEventQueue();
    final PurchaseOutcome outcome = await buy(c, <PurchaseStatus>[
      PurchaseStatus.pending,
      PurchaseStatus.purchased,
    ]);
    expect(outcome, PurchaseOutcome.success);
    expect(store.bought.single.applicationUserName, service.accountToken);
    expect(service.verified.single['transactionId'], '2000000812345678');
    expect(store.completed.length, 1);
    expect(statusRefreshes, 1);
    expect(await queue.entries('userA'), isEmpty);
    expect(c.isPurchasing.value, isFalse);
  });

  test('store pending shows waiting state but never unlocks', () async {
    final SubscriptionController c = build();
    await pumpEventQueue();
    final Future<PurchaseOutcome> outcome = c.purchase(LociIapProducts.monthly);
    await pumpEventQueue();
    store.updates.add(<PurchaseDetails>[storePurchase(PurchaseStatus.pending)]);
    await pumpEventQueue();
    expect(c.isAwaitingApproval.value, isTrue);
    expect(service.verified, isEmpty);
    expect(statusRefreshes, 0);
    // Times out as pending (the stream + queue keep handling it).
    expect(await outcome, PurchaseOutcome.pending);
    expect(c.isPurchasing.value, isFalse);
  });

  test('retryable: NOT completed, kept in queue, retried later without double completion', () async {
    service.verifyResults.add(
      const VerifyResult(VerifyResultKind.retryable, message: 'offline'),
    );
    final SubscriptionController c = build();
    await pumpEventQueue();
    final PurchaseOutcome outcome = await buy(c, <PurchaseStatus>[
      PurchaseStatus.purchased,
    ]);
    expect(outcome, PurchaseOutcome.deferred);
    expect(store.completed, isEmpty);
    expect(statusRefreshes, 0);
    expect(c.infoMessage.value, contains('shortly'));
    expect((await queue.entries('userA')).single.attempts, 1);

    // Connectivity regained, but still in backoff → nothing sent.
    connectivity.add(true);
    await pumpEventQueue();
    expect(service.verified.length, 1);

    // Next launch ignores backoff → verified → removed, status refreshed.
    await c.processPendingQueue(ignoreBackoff: true);
    expect(service.verified.length, 2);
    expect(await queue.entries('userA'), isEmpty);
    expect(statusRefreshes, 1);
    // The queue never finishes or shows success itself.
    expect(store.completed, isEmpty);
  });

  test('PURCHASE_PENDING keeps the transaction open and the queue entry', () async {
    service.verifyResults.add(const VerifyResult(VerifyResultKind.pending));
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(
      await buy(c, <PurchaseStatus>[PurchaseStatus.purchased]),
      PurchaseOutcome.pending,
    );
    expect(store.completed, isEmpty);
    expect((await queue.entries('userA')).length, 1);
  });

  test('INVALID_PURCHASE (other account) completes, clears queue, shows message', () async {
    service.verifyResults.add(
      const VerifyResult(
        VerifyResultKind.invalid,
        message: 'This purchase is linked to another Loci account',
      ),
    );
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(
      await buy(c, <PurchaseStatus>[PurchaseStatus.purchased]),
      PurchaseOutcome.failed,
    );
    expect(store.completed.length, 1);
    expect(await queue.entries('userA'), isEmpty);
    expect(c.errorMessage.value, contains('another Loci account'));
    expect(statusRefreshes, 0);
  });

  test('user cancels the store sheet', () async {
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(
      await buy(c, <PurchaseStatus>[PurchaseStatus.canceled]),
      PurchaseOutcome.cancelled,
    );
    expect(service.verified, isEmpty);
  });

  test('purchase still works without the account token (legacy path)', () async {
    service.tokenFails = true;
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(
      await buy(c, <PurchaseStatus>[PurchaseStatus.purchased]),
      PurchaseOutcome.success,
    );
    expect(store.bought.single.applicationUserName, isNull);
  });

  test('signed out: purchase blocked; delivered transactions stay open', () async {
    userId = null;
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(await c.purchase(LociIapProducts.monthly), PurchaseOutcome.failed);
    store.updates.add(<PurchaseDetails>[storePurchase(PurchaseStatus.purchased)]);
    await pumpEventQueue();
    expect(service.verified, isEmpty);
    expect(store.completed, isEmpty);
  });

  test("never verifies user A's queued purchase while user B is signed in", () async {
    await queue.save('userA', <String, dynamic>{
      'platform': 'apple',
      'productId': LociIapProducts.monthly,
      'transactionId': 'A-1',
    });
    userId = 'userB';
    build();
    await pumpEventQueue();
    expect(service.verified, isEmpty);

    // Switch back to A → A's queue is processed.
    userId = 'userA';
    session.add('userA');
    await pumpEventQueue();
    expect(service.verified.single['transactionId'], 'A-1');
    expect(await queue.entries('userA'), isEmpty);
  });

  test('queued entry is retried on launch (crash between purchase and verify)', () async {
    await queue.save('userA', <String, dynamic>{
      'platform': 'google',
      'productId': LociIapProducts.monthly,
      'purchaseToken': 'tok',
    });
    build(platform: StorePlatform.google);
    await pumpEventQueue();
    expect(service.verified.single['purchaseToken'], 'tok');
    expect(await queue.entries('userA'), isEmpty);
    expect(statusRefreshes, 1);
  });

  test('restore verifies restored items and reports the result', () async {
    store.restoreResult = <PurchaseDetails>[
      storePurchase(PurchaseStatus.restored),
    ];
    final SubscriptionController c = build();
    await pumpEventQueue();
    await c.restorePurchases();
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(store.restoredWith.single, service.accountToken);
    expect(service.verified.length, 1);
    expect(c.infoMessage.value, 'Your purchases have been restored.');
    expect(c.isRestoring.value, isFalse);
    expect(statusRefreshes, greaterThanOrEqualTo(1));
  });

  test('restore of an expired subscription shows the server message', () async {
    service.verifyResults.add(
      const VerifyResult(
        VerifyResultKind.invalid,
        message: 'This subscription has expired',
      ),
    );
    store.restoreResult = <PurchaseDetails>[
      storePurchase(PurchaseStatus.restored),
    ];
    final SubscriptionController c = build();
    await pumpEventQueue();
    await c.restorePurchases();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(c.errorMessage.value, 'This subscription has expired');
  });

  test('restore with nothing to restore', () async {
    final SubscriptionController c = build();
    await pumpEventQueue();
    await c.restorePurchases();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(c.infoMessage.value, 'No purchases to restore.');
    expect(c.isRestoring.value, isFalse);
  });

  test('unfinished StoreKit transactions are recovered at launch and verified', () async {
    unfinished = <PurchaseDetails>[storePurchase(PurchaseStatus.purchased)];
    service.verifyResults.add(
      const VerifyResult(VerifyResultKind.invalid, message: 'rejected'),
    );
    build();
    await pumpEventQueue();
    expect(service.verified.single['transactionId'], '2000000812345678');
    // INVALID_PURCHASE is definitive → finished, not lost or looping.
    expect(store.completed.length, 1);
    expect(statusRefreshes, 0);
  });

  test('recovery waits for sign-in', () async {
    unfinished = <PurchaseDetails>[storePurchase(PurchaseStatus.purchased)];
    userId = null;
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(service.verified, isEmpty);
    userId = 'userA';
    session.add('userA');
    await pumpEventQueue();
    expect(service.verified.length, 1);
    expect(c.isPurchasing.value, isFalse);
  });

  test('store exceptions never surface raw stack traces', () {
    final String msg = SubscriptionController.friendlyError(
      PlatformException(
        code: 'unknown',
        message: 'StoreKitError',
        details: 'Stacktrace: ["0 in_app_purchase_storekit 0x0000…"]',
      ),
    );
    expect(msg, isNot(contains('Stacktrace')));
    expect(msg, isNot(contains('PlatformException')));
    expect(msg, contains('Restore Purchases'));
    expect(
      SubscriptionController.friendlyError(Exception('No internet')),
      'No internet',
    );
  });
}
