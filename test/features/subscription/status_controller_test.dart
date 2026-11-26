import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSubscriptionService service;
  late bool canAccess;
  late StreamController<Object?> session;

  SubscriptionStatusController build() {
    final SubscriptionStatusController c = SubscriptionStatusController(
      service,
      canAccess: () => canAccess,
      sessionChanges: session.stream,
      observeLifecycle: false,
    );
    Get.put(c);
    return c;
  }

  setUp(() {
    Get.testMode = true;
    service = FakeSubscriptionService();
    canAccess = true;
    session = StreamController<Object?>.broadcast();
  });

  tearDown(() async {
    Get.reset();
    await session.close();
  });

  test('200 with data → paid; credits pre-check', () async {
    service.subscriptionResult = activeSubscription(remaining: 15);
    final SubscriptionStatusController c = build();
    await pumpEventQueue();
    expect(c.hasLoaded.value, isTrue);
    expect(c.canCreatePaidContent, isTrue);
    expect(c.canSubmitSpotlight, isTrue);
    service.subscriptionResult = activeSubscription(remaining: 5);
    await c.reload();
    expect(c.canSubmitSpotlight, isFalse);
  });

  test('200 with data:null → free', () async {
    final SubscriptionStatusController c = build();
    await pumpEventQueue();
    expect(c.isFree, isTrue);
    expect(c.canCreatePaidContent, isFalse);
  });

  test('network error keeps the last known status (never downgrades to free)', () async {
    service.subscriptionResult = activeSubscription();
    final SubscriptionStatusController c = build();
    await pumpEventQueue();
    service.subscriptionError = Exception('No internet connection');
    await c.reload();
    expect(c.subscription.value, isNotNull);
    expect(c.isFree, isFalse);
    expect(c.errorMessage.value, 'No internet connection');
  });

  test('network error before any answer is not "free"', () async {
    service.subscriptionError = Exception('timeout');
    final SubscriptionStatusController c = build();
    await pumpEventQueue();
    expect(c.hasLoaded.value, isFalse);
    expect(c.isFree, isFalse);
  });

  test('members never call the endpoint', () async {
    canAccess = false;
    build();
    await pumpEventQueue();
    expect(service.statusCalls, 0);
  });

  test('no business → nothing to fetch', () async {
    service.businessIds = <String>[];
    final SubscriptionStatusController c = build();
    await pumpEventQueue();
    expect(c.hasNoBusiness.value, isTrue);
    expect(service.statusCalls, 0);
  });

  test('concurrent reloads share one request', () async {
    final SubscriptionStatusController c = build();
    await pumpEventQueue();
    final int before = service.statusCalls;
    await Future.wait(<Future<void>>[c.reload(), c.reload(), c.reload()]);
    expect(service.statusCalls, before + 1);
  });

  test('account switch clears the previous user status and reloads', () async {
    service.subscriptionResult = activeSubscription();
    final SubscriptionStatusController c = build();
    await pumpEventQueue();
    expect(c.subscription.value, isNotNull);
    service.subscriptionResult = null;
    session.add('userB');
    await pumpEventQueue();
    expect(c.subscription.value, isNull);
    expect(c.isFree, isTrue);
  });
}
