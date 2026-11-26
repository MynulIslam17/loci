import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:loci/core/iap/iap.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(IapService, FakeStore, List<IapEvent>)> setUpService(
    IapVerificationResult Function(PurchaseDetails) verify, {
    bool isAndroid = false,
    GooglePastPurchasesLoader? past,
  }) async {
    final FakeStore store = FakeStore();
    final IapService service = IapService(
      config: const IapConfig(productIds: LociIapProducts.all),
      store: store,
      isAndroid: isAndroid,
      googlePastPurchases: past,
      verifyPurchase: (PurchaseDetails p) async => verify(p),
    );
    final List<IapEvent> events = <IapEvent>[];
    service.events.listen(events.add);
    await service.initialize();
    return (service, store, events);
  }

  final Map<IapVerification, (bool, IapEventType)> table =
      <IapVerification, (bool, IapEventType)>{
        IapVerification.verified: (true, IapEventType.purchaseCompleted),
        IapVerification.rejected: (true, IapEventType.verificationFailed),
        IapVerification.pending: (false, IapEventType.verificationPending),
        IapVerification.retryLater: (false, IapEventType.verificationDeferred),
      };

  for (final MapEntry<IapVerification, (bool, IapEventType)> row
      in table.entries) {
    test(
      '${row.key} → completes: ${row.value.$1}, emits ${row.value.$2}',
      () async {
        final (
          IapService service,
          FakeStore store,
          List<IapEvent> events,
        ) = await setUpService(
          (_) => IapVerificationResult(row.key, message: 'm'),
        );
        store.updates.add(<PurchaseDetails>[
          storePurchase(PurchaseStatus.purchased),
        ]);
        await pumpEventQueue();
        expect(store.completed.length, row.value.$1 ? 1 : 0);
        expect(events.last.type, row.value.$2);
        expect(events.last.message, 'm');
        await service.dispose();
      },
    );
  }

  test(
    'a purchase without purchaseID is finished through the fallback, not the plugin',
    () async {
      final FakeStore store = FakeStore();
      final List<PurchaseDetails> finishedById = <PurchaseDetails>[];
      final IapService service = IapService(
        config: const IapConfig(productIds: LociIapProducts.all),
        store: store,
        verifyPurchase: (_) async =>
            const IapVerificationResult(IapVerification.rejected),
        finishWithoutPurchaseId: (PurchaseDetails p) async {
          finishedById.add(p);
          return true;
        },
      );
      final List<IapEvent> events = <IapEvent>[];
      service.events.listen(events.add);
      await service.initialize();
      store.updates.add(<PurchaseDetails>[
        storePurchase(PurchaseStatus.purchased, purchaseId: null),
      ]);
      await pumpEventQueue();
      expect(finishedById.length, 1);
      expect(store.completed, isEmpty);
      expect(events.any((IapEvent e) => e.type == IapEventType.error), isFalse);
      expect(events.last.type, IapEventType.verificationFailed);
      await service.dispose();
    },
  );

  test('restored + verified emits purchaseRestored', () async {
    final (
      IapService service,
      FakeStore store,
      List<IapEvent> events,
    ) = await setUpService(
      (_) => const IapVerificationResult(IapVerification.verified),
    );
    store.updates.add(<PurchaseDetails>[
      storePurchase(PurchaseStatus.restored),
    ]);
    await pumpEventQueue();
    expect(events.last.type, IapEventType.purchaseRestored);
    await service.dispose();
  });

  test(
    'a throwing verifier is treated as retry-later (never completes)',
    () async {
      final (IapService service, FakeStore store, List<IapEvent> events) =
          await setUpService((_) => throw Exception('boom'));
      store.updates.add(<PurchaseDetails>[
        storePurchase(PurchaseStatus.purchased),
      ]);
      await pumpEventQueue();
      expect(store.completed, isEmpty);
      expect(events.last.type, IapEventType.verificationDeferred);
      await service.dispose();
    },
  );

  test('store pending is never verified nor completed', () async {
    int calls = 0;
    final (
      IapService service,
      FakeStore store,
      List<IapEvent> events,
    ) = await setUpService((_) {
      calls++;
      return const IapVerificationResult(IapVerification.verified);
    });
    store.updates.add(<PurchaseDetails>[storePurchase(PurchaseStatus.pending)]);
    await pumpEventQueue();
    expect(calls, 0);
    expect(store.completed, isEmpty);
    expect(events.last.type, IapEventType.purchasePending);
    await service.dispose();
  });

  test(
    'canceled / error purchases are finished without verification',
    () async {
      final (IapService service, FakeStore store, _) = await setUpService(
        (_) => throw StateError('should not verify'),
      );
      store.updates.add(<PurchaseDetails>[
        storePurchase(PurchaseStatus.canceled),
        storePurchase(PurchaseStatus.error, purchaseId: 'other'),
      ]);
      await pumpEventQueue();
      expect(store.completed.length, 2);
      await service.dispose();
    },
  );

  test('unknown products are finished, not verified', () async {
    final (IapService service, FakeStore store, _) = await setUpService(
      (_) => throw StateError('should not verify'),
    );
    store.updates.add(<PurchaseDetails>[
      storePurchase(PurchaseStatus.purchased, productId: 'other.product'),
    ]);
    await pumpEventQueue();
    expect(store.completed.length, 1);
    await service.dispose();
  });

  test('purchase + restore pass the account token', () async {
    final (IapService service, FakeStore store, _) = await setUpService(
      (_) => const IapVerificationResult(IapVerification.verified),
    );
    await service.purchase(LociIapProducts.monthly, applicationUserName: 'tok');
    expect(store.bought.single.applicationUserName, 'tok');
    expect(store.bought.single, isNot(isA<GooglePlayPurchaseParam>()));
    await service.restorePurchases(applicationUserName: 'tok');
    expect(store.restoredWith, <String?>['tok']);
    await service.dispose();
  });

  test('android plan switch replaces the existing subscription', () async {
    final GooglePlayPurchaseDetails monthly = GooglePlayPurchaseDetails(
      productID: LociIapProducts.monthly,
      purchaseID: 'GPA.1',
      verificationData: PurchaseVerificationData(
        localVerificationData: '',
        serverVerificationData: 'tok',
        source: 'google_play',
      ),
      transactionDate: '1',
      billingClientPurchase: _purchaseWrapper(),
      status: PurchaseStatus.purchased,
    );
    final (IapService service, FakeStore store, _) = await setUpService(
      (_) => const IapVerificationResult(IapVerification.verified),
      isAndroid: true,
      past: () async => <GooglePlayPurchaseDetails>[monthly],
    );
    await service.purchase(LociIapProducts.yearly, applicationUserName: 't');
    final GooglePlayPurchaseParam param =
        store.bought.single as GooglePlayPurchaseParam;
    expect(param.applicationUserName, 't');
    expect(param.changeSubscriptionParam?.oldPurchaseDetails, same(monthly));

    // Buying the same product again is not a switch.
    store.bought.clear();
    await service.purchase(LociIapProducts.monthly);
    expect(
      (store.bought.single as GooglePlayPurchaseParam).changeSubscriptionParam,
      isNull,
    );
    await service.dispose();
  });
}

PurchaseWrapper _purchaseWrapper() => PurchaseWrapper(
  orderId: 'GPA.1',
  packageName: 'ui.neatboutique.jacobi',
  purchaseTime: 0,
  purchaseToken: 'tok',
  signature: 'sig',
  products: <String>[LociIapProducts.monthly],
  isAutoRenewing: true,
  originalJson: '{}',
  isAcknowledged: true,
  purchaseState: PurchaseStateWrapper.purchased,
);
