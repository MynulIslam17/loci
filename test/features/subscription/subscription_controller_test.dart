import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/subscription/presentation/subscription_messages.dart';
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
  late MemoryQueueStore switchStore;

  List<PurchaseDetails> unfinished = <PurchaseDetails>[];

  SubscriptionController build({
    StorePlatform platform = StorePlatform.apple,
    DateTime Function()? clock,
  }) {
    final SubscriptionController c = SubscriptionController(
      clock: clock,
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
      switchStore: switchStore,
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
    switchStore = MemoryQueueStore();
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

  test(
    'success: token attached, verified, completed, status refreshed, queue empty',
    () async {
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
    },
  );

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

  test(
    'retryable: NOT completed, kept in queue, retried later without double completion',
    () async {
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
    },
  );

  test(
    'PURCHASE_PENDING keeps the transaction open and the queue entry',
    () async {
      service.verifyResults.add(const VerifyResult(VerifyResultKind.pending));
      final SubscriptionController c = build();
      await pumpEventQueue();
      expect(
        await buy(c, <PurchaseStatus>[PurchaseStatus.purchased]),
        PurchaseOutcome.pending,
      );
      expect(store.completed, isEmpty);
      expect((await queue.entries('userA')).length, 1);
    },
  );

  test(
    'INVALID_PURCHASE (other account) completes, clears queue, shows message',
    () async {
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
    },
  );

  test('user cancels the store sheet', () async {
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(
      await buy(c, <PurchaseStatus>[PurchaseStatus.canceled]),
      PurchaseOutcome.cancelled,
    );
    expect(service.verified, isEmpty);
  });

  test(
    'purchase still works without the account token (legacy path)',
    () async {
      service.tokenFails = true;
      final SubscriptionController c = build();
      await pumpEventQueue();
      expect(
        await buy(c, <PurchaseStatus>[PurchaseStatus.purchased]),
        PurchaseOutcome.success,
      );
      expect(store.bought.single.applicationUserName, isNull);
    },
  );

  test(
    'signed out: purchase blocked; delivered transactions stay open',
    () async {
      userId = null;
      final SubscriptionController c = build();
      await pumpEventQueue();
      expect(await c.purchase(LociIapProducts.monthly), PurchaseOutcome.failed);
      store.updates.add(<PurchaseDetails>[
        storePurchase(PurchaseStatus.purchased),
      ]);
      await pumpEventQueue();
      expect(service.verified, isEmpty);
      expect(store.completed, isEmpty);
    },
  );

  test(
    "never verifies user A's queued purchase while user B is signed in",
    () async {
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
    },
  );

  test(
    'queued entry is retried on launch (crash between purchase and verify)',
    () async {
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
    },
  );

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

  test('restore waits for a slow backend instead of reporting nothing', () async {
    // Verification takes far longer than the 20ms quiet period — as on a real
    // phone, where the restored transaction reaches the backend over the network.
    service.verifyDelay = const Duration(milliseconds: 150);
    store.restoreResult = <PurchaseDetails>[
      storePurchase(PurchaseStatus.restored),
    ];
    final SubscriptionController c = build();
    await pumpEventQueue();
    final Future<RestoreOutcome> result = c.restorePurchases();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(c.isRestoring.value, isTrue, reason: 'still verifying');
    expect(c.infoMessage.value, isNot('No purchases to restore.'));
    expect(await result, RestoreOutcome.restored);
    expect(service.verified.length, 1);
    expect(c.infoMessage.value, 'Your purchases have been restored.');
    expect(c.isRestoring.value, isFalse);
  });

  test('restore with nothing to restore', () async {
    final SubscriptionController c = build();
    await pumpEventQueue();
    expect(await c.restorePurchases(), RestoreOutcome.nothing);
    expect(c.infoMessage.value, 'No purchases to restore.');
    expect(c.isRestoring.value, isFalse);
  });

  test(
    'unfinished StoreKit transactions are recovered at launch and verified',
    () async {
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
    },
  );

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

  group('production-grade error handling', () {
    const String jwsDebug =
        'Invalid Apple signed data: certificate chain must contain exactly 3 certificates';

    test(
      'technical INVALID_PURCHASE text is never shown on purchase',
      () async {
        service.verifyResults.add(
          const VerifyResult(VerifyResultKind.invalid, message: jwsDebug),
        );
        final SubscriptionController c = build();
        await pumpEventQueue();
        final PurchaseOutcome outcome = await buy(c, <PurchaseStatus>[
          PurchaseStatus.purchased,
        ]);
        expect(outcome, PurchaseOutcome.failed);
        expect(c.errorMessage.value, SubscriptionMessages.purchaseUnverified);
      },
    );

    test('technical INVALID_PURCHASE text is never shown on restore', () async {
      service.verifyResults.add(
        const VerifyResult(VerifyResultKind.invalid, message: jwsDebug),
      );
      store.restoreResult = <PurchaseDetails>[
        storePurchase(PurchaseStatus.restored),
      ];
      final SubscriptionController c = build();
      await pumpEventQueue();
      await c.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(c.errorMessage.value, SubscriptionMessages.restoredInactive);
    });

    test(
      'a verified purchase stays successful if finishing it fails',
      () async {
        store.completeError = PlatformException(code: 'storekit_finish');
        final SubscriptionController c = build();
        await pumpEventQueue();
        final PurchaseOutcome outcome = await buy(c, <PurchaseStatus>[
          PurchaseStatus.purchased,
        ]);
        expect(outcome, PurchaseOutcome.success);
        expect(c.errorMessage.value, isNull);
      },
    );

    test(
      'store purchase failure shows friendly copy, not StoreKit text',
      () async {
        final SubscriptionController c = build();
        await pumpEventQueue();
        final Future<PurchaseOutcome> outcome = c.purchase(
          LociIapProducts.monthly,
        );
        await pumpEventQueue();
        final PurchaseDetails failed = storePurchase(PurchaseStatus.error)
          ..error = IAPError(
            source: 'app_store',
            code: 'storekit2_purchase_failed',
            message:
                'SKErrorDomain Code=0 "(null)" UserInfo={NSUnderlyingError=0x6000}',
          );
        store.updates.add(<PurchaseDetails>[failed]);
        await pumpEventQueue();
        expect(await outcome, PurchaseOutcome.failed);
        expect(c.errorMessage.value, SubscriptionMessages.storeFailed);
      },
    );

    test('missing store products show a friendly message', () async {
      store.notFound = LociIapProducts.all;
      final SubscriptionController c = build();
      await pumpEventQueue();
      expect(c.errorMessage.value, SubscriptionMessages.plansUnavailable);
    });

    test('one missing product still shows the other plan, no error', () async {
      store.notFound = <String>{LociIapProducts.yearly};
      final SubscriptionController c = build();
      await pumpEventQueue();
      expect(c.errorMessage.value, isNull);
      expect(c.productFor(LociIapProducts.monthly), isNotNull);
    });
  });

  group('plan switches and concurrency', () {
    test('opens on the current plan; unknown product keeps the default', () {
      final SubscriptionController c = build();
      expect(c.selectedPlan.value?.productId, LociIapProducts.monthly);
      c.selectPlanForProduct(LociIapProducts.yearly);
      expect(c.selectedPlan.value?.productId, LociIapProducts.yearly);
      c.selectPlanForProduct('com.example.unknown');
      c.selectPlanForProduct(null);
      expect(c.selectedPlan.value?.productId, LociIapProducts.yearly);
    });

    final DateTime now = DateTime.utc(2026, 11, 26, 6, 20);
    final DateTime monthlyBought = DateTime.utc(2026, 11, 26, 5, 19, 34);
    final DateTime monthlyExpires = DateTime.utc(2026, 11, 27, 5, 19, 34);

    String jws(Map<String, Object?> payload) {
      String part(Object o) =>
          base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
      return '${part(<String, String>{'alg': 'ES256'})}.${part(payload)}.c2ln';
    }

    PurchaseDetails monthlyTx({
      required DateTime purchased,
      String id = '2000001271458558',
    }) => storePurchase(
      PurchaseStatus.purchased,
      productId: LociIapProducts.monthly,
      purchaseId: id,
      evidence: jws(<String, Object?>{
        'transactionId': id,
        'originalTransactionId': '2000001257668012',
        'productId': LociIapProducts.monthly,
        'purchaseDate': purchased.millisecondsSinceEpoch,
        'expiresDate': monthlyExpires.millisecondsSinceEpoch,
      }),
    );

    test(
      'downgrade answered with the existing transaction is "scheduled", not a hang',
      () async {
        final SubscriptionController c = build(clock: () => now);
        await pumpEventQueue();
        final Future<PurchaseOutcome> outcome = c.purchase(
          LociIapProducts.yearly,
        );
        await pumpEventQueue();
        store.updates.add(<PurchaseDetails>[
          monthlyTx(purchased: monthlyBought),
        ]);
        await pumpEventQueue();
        expect(
          await outcome.timeout(const Duration(milliseconds: 200)),
          PurchaseOutcome.scheduled,
        );
        expect(c.isPurchasing.value, isFalse);
        expect(c.infoMessage.value, contains('switch to Yearly is scheduled'));
        expect(c.infoMessage.value, contains('You keep Monthly'));
        expect(
          service.verified.length,
          1,
          reason: 'existing tx still verified once',
        );
        expect(c.isSwitchScheduled(LociIapProducts.yearly), isTrue);
        expect(c.isSwitchScheduled(LociIapProducts.monthly), isFalse);
      },
    );

    test('scheduled switch is forgotten on account change', () async {
      final SubscriptionController c = build(clock: () => now);
      await pumpEventQueue();
      final Future<PurchaseOutcome> outcome = c.purchase(
        LociIapProducts.yearly,
      );
      await pumpEventQueue();
      store.updates.add(<PurchaseDetails>[monthlyTx(purchased: monthlyBought)]);
      await pumpEventQueue();
      await outcome;
      expect(c.isSwitchScheduled(LociIapProducts.yearly), isTrue);
      userId = 'userB';
      session.add('userB|business_owner');
      await pumpEventQueue();
      expect(c.isSwitchScheduled(LociIapProducts.yearly), isFalse);
    });

    Future<void> scheduleYearly(SubscriptionController c) async {
      await pumpEventQueue();
      final Future<PurchaseOutcome> outcome = c.purchase(
        LociIapProducts.yearly,
      );
      await pumpEventQueue();
      store.updates.add(<PurchaseDetails>[monthlyTx(purchased: monthlyBought)]);
      await pumpEventQueue();
      expect(await outcome, PurchaseOutcome.scheduled);
      await pumpEventQueue();
      // Simulate the app being killed before the next launch.
      Get.delete<SubscriptionController>(force: true);
    }

    test('Apple returns another plan\'s old transaction and the backend never '
        'answers → "almost done" right away, never a silent reset', () async {
      service.defaultVerify = const VerifyResult(VerifyResultKind.retryable);
      final SubscriptionController c = build(clock: () => now);
      await pumpEventQueue();
      final Future<PurchaseOutcome> outcome = c.purchase(
        LociIapProducts.yearly,
      );
      await pumpEventQueue();
      store.updates.add(<PurchaseDetails>[monthlyTx(purchased: monthlyBought)]);
      await pumpEventQueue();
      expect(await outcome, PurchaseOutcome.deferred);
      expect(c.infoMessage.value, isNotNull);
      expect(c.isPurchasing.value, isFalse);
    });

    test('existing subscription owned by another Loci account fails at once '
        'with a clear message', () async {
      service.defaultVerify = const VerifyResult(
        VerifyResultKind.invalid,
        message: 'This purchase was made from a different Loci account',
      );
      final SubscriptionController c = build(clock: () => now);
      await pumpEventQueue();
      final Future<PurchaseOutcome> outcome = c.purchase(
        LociIapProducts.yearly,
      );
      await pumpEventQueue();
      store.updates.add(<PurchaseDetails>[monthlyTx(purchased: monthlyBought)]);
      await pumpEventQueue();
      expect(await outcome, PurchaseOutcome.failed);
      expect(c.errorMessage.value, contains('different Loci account'));
      expect(c.errorMessage.value, contains('Apple ID'));
      expect(c.isPurchasing.value, isFalse);
    });

    test('scheduled switch survives an app restart', () async {
      final SubscriptionController first = build(clock: () => now);
      await scheduleYearly(first);
      final SubscriptionController relaunched = build(clock: () => now);
      await pumpEventQueue();
      expect(relaunched.isSwitchScheduled(LociIapProducts.yearly), isTrue);
    });

    test('a saved switch is ignored for another account', () async {
      await scheduleYearly(build(clock: () => now));
      userId = 'userB';
      final SubscriptionController other = build(clock: () => now);
      await pumpEventQueue();
      expect(other.isSwitchScheduled(LociIapProducts.yearly), isFalse);
    });

    test('a saved switch expires when the billing period ends', () async {
      await scheduleYearly(build(clock: () => now));
      final SubscriptionController later = build(
        clock: () => monthlyExpires.add(const Duration(minutes: 1)),
      );
      await pumpEventQueue();
      expect(later.isSwitchScheduled(LociIapProducts.yearly), isFalse);
      expect(await switchStore.read('loci.iap.scheduled_switch.v1'), isNull);
    });

    test(
      'a brand-new other-plan transaction (renewal) does not end the purchase',
      () async {
        final SubscriptionController c = build(clock: () => now);
        await pumpEventQueue();
        final Future<PurchaseOutcome> outcome = c.purchase(
          LociIapProducts.yearly,
        );
        await pumpEventQueue();
        store.updates.add(<PurchaseDetails>[
          monthlyTx(purchased: now, id: '2000001299999999'),
        ]);
        await pumpEventQueue();
        expect(c.isPurchasing.value, isTrue);
        store.updates.add(<PurchaseDetails>[
          storePurchase(
            PurchaseStatus.purchased,
            productId: LociIapProducts.yearly,
          ),
        ]);
        await pumpEventQueue();
        expect(await outcome, PurchaseOutcome.success);
      },
    );

    test(
      'a resume-time queue retry never re-sends a purchase being verified',
      () async {
        service.verifyDelay = const Duration(milliseconds: 80);
        final SubscriptionController c = build();
        await pumpEventQueue();
        final Future<PurchaseOutcome> outcome = c.purchase(
          LociIapProducts.monthly,
        );
        await pumpEventQueue();
        store.updates.add(<PurchaseDetails>[
          storePurchase(PurchaseStatus.purchased),
        ]);
        await pumpEventQueue();
        // App resumes after the store sheet closes → queue retry fires.
        await c.processPendingQueue(ignoreBackoff: true);
        expect(await outcome, PurchaseOutcome.success);
        expect(service.verified.length, 1);
      },
    );

    test('stale restore message is cleared when choosing a plan', () async {
      final SubscriptionController c = build();
      await pumpEventQueue();
      await c.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(c.infoMessage.value, isNotNull);
      c.selectPlan(c.plans.last);
      expect(c.infoMessage.value, isNull);
    });

    test('scheduledSwitchMessage', () {
      expect(
        scheduledSwitchMessage(
          newPlan: 'Yearly',
          currentPlan: 'Monthly',
          startsAt: DateTime(2026, 11, 27),
        ),
        'Your switch to Yearly is scheduled. You keep Monthly until it renews '
        'on Nov 27, 2026, then Yearly starts.',
      );
      expect(
        scheduledSwitchMessage(newPlan: 'Yearly', currentPlan: 'Monthly'),
        contains('when your current billing period ends'),
      );
    });
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
