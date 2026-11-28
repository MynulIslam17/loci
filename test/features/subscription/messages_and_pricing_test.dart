import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/subscription_messages.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_dialogs.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_selection_view.dart';

import 'fakes.dart';

MySubscriptionModel sub({
  String provider = 'apple',
  String billingType = 'monthly',
  int amount = 2900,
}) => MySubscriptionModel.fromJson(<String, dynamic>{
  'status': 'active',
  'planId': billingType,
  'planName': billingType == 'yearly' ? 'Yearly' : 'Monthly',
  'billingType': billingType,
  'provider': provider,
  'amount': amount,
  'currency': 'usd',
});

void main() {
  group('friendlySubscriptionError', () {
    test('connectivity failures', () {
      expect(
        friendlySubscriptionError(const SocketException('Failed host lookup')),
        SubscriptionMessages.offline,
      );
      expect(
        friendlySubscriptionError(TimeoutException('verify')),
        SubscriptionMessages.offline,
      );
    });

    test('store errors map by meaning, never raw text', () {
      expect(
        friendlySubscriptionError(PlatformException(code: 'userCancelled')),
        SubscriptionMessages.purchaseCancelled,
      );
      expect(
        friendlySubscriptionError(
          IAPError(
            source: 'app_store',
            code: 'storekit_error',
            message: 'The network connection was lost.',
          ),
        ),
        SubscriptionMessages.storeOffline,
      );
      expect(
        friendlySubscriptionError(
          PlatformException(code: 'unknown', details: 'Stacktrace: 0x0001'),
        ),
        SubscriptionMessages.storeFailed,
      );
    });

    test('technical exception text falls back; friendly text passes', () {
      expect(
        friendlySubscriptionError(
          Exception(
            'Invalid Apple signed data: certificate chain must contain exactly 3 certificates',
          ),
          fallback: 'F',
        ),
        'F',
      );
      expect(
        friendlySubscriptionError(
          Exception("type 'Null' is not a subtype of type 'String'"),
          fallback: 'F',
        ),
        'F',
      );
      expect(
        friendlySubscriptionError(StateError('Bad state'), fallback: 'F'),
        'F',
      );
      expect(
        friendlySubscriptionError(Exception('No internet connection')),
        'No internet connection',
      );
    });

    test('isUserFacingMessage', () {
      expect(
        isUserFacingMessage('This purchase belongs to another Loci account.'),
        isTrue,
      );
      expect(isUserFacingMessage('This subscription has expired'), isTrue);
      for (final String? bad in <String?>[
        'Invalid Apple signed data: certificate chain must contain exactly 3 certificates',
        'TypeError: Cannot read properties of undefined (reading \'x\')',
        'MongoServerError: E11000 duplicate key',
        '{"error":"internal"}',
        '<html>502 Bad Gateway</html>',
        'connect ECONNREFUSED 127.0.0.1:5432',
        '',
        null,
      ]) {
        expect(isUserFacingMessage(bad), isFalse, reason: bad);
      }
    });
  });

  group('displayPrice', () {
    test('uses Apple\'s localized price for store subscriptions', () {
      expect(
        MySubscriptionController.displayPrice(sub(), storePrice: '\$29.99'),
        '\$29.99',
      );
    });

    test('falls back to the server amount when the product is not loaded', () {
      expect(MySubscriptionController.displayPrice(sub()), '\$29');
    });

    test('legacy (Stripe) plans keep the server amount', () {
      expect(
        MySubscriptionController.displayPrice(
          sub(provider: 'stripe'),
          storePrice: '\$29.99',
        ),
        '\$29',
      );
    });
  });

  group('planButtonState', () {
    test('no subscription → continue', () {
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Monthly',
        selectedProductId: 'ui.neatboutique.jacobi.business.monthly',
        selectedIsPaid: true,
        current: null,
      );
      expect(s.label, 'Continue with Monthly');
      expect(s.enabled, isTrue);
    });

    test('current plan cannot be bought again', () {
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Monthly',
        selectedProductId: 'ui.neatboutique.jacobi.business.monthly',
        selectedIsPaid: true,
        current: sub(),
      );
      expect(s.label, 'Your current plan');
      expect(s.enabled, isFalse);
    });

    test('other paid plan is a switch', () {
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Yearly',
        selectedProductId: 'ui.neatboutique.jacobi.business.yearly',
        selectedIsPaid: true,
        current: sub(),
      );
      expect(s.label, 'Switch to Yearly');
      expect(s.enabled, isTrue);
    });

    test('already-scheduled switch is disabled', () {
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Yearly',
        selectedProductId: 'ui.neatboutique.jacobi.business.yearly',
        selectedIsPaid: true,
        current: sub(),
        scheduledProductId: 'ui.neatboutique.jacobi.business.yearly',
      );
      expect(s.label, 'Switch scheduled');
      expect(s.enabled, isFalse);
    });

    test('backend pendingPlanId marks the switch as scheduled', () {
      final MySubscriptionModel current =
          MySubscriptionModel.fromJson(<String, dynamic>{
            'status': 'active',
            'planId': 'monthly',
            'billingType': 'monthly',
            'provider': 'apple',
            'pendingPlanId': 'yearly',
            'pendingPlanName': 'Yearly',
          });
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Yearly',
        selectedProductId: 'ui.neatboutique.jacobi.business.yearly',
        selectedIsPaid: true,
        current: current,
      );
      expect(s.label, 'Switch scheduled');
      expect(s.enabled, isFalse);
    });

    test('once the scheduled plan is current, it shows as current', () {
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Yearly',
        selectedProductId: 'ui.neatboutique.jacobi.business.yearly',
        selectedIsPaid: true,
        current: sub(billingType: 'yearly'),
        scheduledProductId: 'ui.neatboutique.jacobi.business.yearly',
      );
      expect(s.label, 'Your current plan');
      expect(s.enabled, isFalse);
    });

    test('free plan is not purchasable while subscribed', () {
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Free',
        selectedProductId: null,
        selectedIsPaid: false,
        current: sub(),
      );
      expect(s.enabled, isFalse);
    });
  });

  group('status errors', () {
    setUp(() => Get.testMode = true);
    tearDown(Get.reset);

    Future<SubscriptionStatusController> statusWith(Object error) async {
      final FakeSubscriptionService service = FakeSubscriptionService()
        ..subscriptionError = error;
      final SubscriptionStatusController c = SubscriptionStatusController(
        service,
        canAccess: () => true,
        observeLifecycle: false,
      );
      c.onInit();
      await pumpEventQueue();
      return c;
    }

    test('technical failure shows friendly copy', () async {
      final SubscriptionStatusController c = await statusWith(
        Exception('MongoServerError: connection pool closed'),
      );
      expect(c.errorMessage.value, SubscriptionMessages.statusUnavailable);
    });

    test('programmer error shows friendly copy', () async {
      final SubscriptionStatusController c = await statusWith(TypeError());
      expect(c.errorMessage.value, SubscriptionMessages.statusUnavailable);
    });
  });

  group('dialog copy', () {
    test('switch confirmation names both plans and prices', () {
      final DialogCopy c = switchConfirmCopy(
        currentPlan: 'Monthly',
        currentPrice: '\$29.99 / month',
        newPlan: 'Yearly',
        newPrice: '\$290.00 / year',
        isIOS: true,
      );
      expect(c.title, 'Switch to Yearly?');
      expect(c.message, contains('Monthly (\$29.99 / month)'));
      expect(c.message, contains('Yearly is \$290.00 / year'));
      expect(c.message, contains('App Store'));
      expect(c.message, contains('charged twice'));
    });

    test('purchase results: success and cancel need no dialog', () {
      expect(purchaseResultCopy(PurchaseOutcome.success), isNull);
      expect(purchaseResultCopy(PurchaseOutcome.cancelled), isNull);
      expect(purchaseResultCopy(PurchaseOutcome.failed), isNull);
      expect(
        purchaseResultCopy(PurchaseOutcome.scheduled, info: 'X')?.title,
        'Switch scheduled',
      );
      expect(
        purchaseResultCopy(PurchaseOutcome.failed, error: 'E')?.message,
        'E',
      );
      expect(purchaseResultCopy(PurchaseOutcome.pending)?.message, isNotEmpty);
    });

    test('every restore outcome has a title and a message', () {
      for (final RestoreOutcome o in RestoreOutcome.values) {
        final DialogCopy c = restoreResultCopy(o, isIOS: true);
        expect(c.title, isNotEmpty, reason: o.name);
        expect(c.message, isNotEmpty, reason: o.name);
      }
      expect(
        restoreResultCopy(RestoreOutcome.nothing, isIOS: false).message,
        contains('Google account'),
      );
    });
  });

  group('current plan banner', () {
    MySubscriptionModel withFields(Map<String, dynamic> extra) =>
        MySubscriptionModel.fromJson(<String, dynamic>{
          'status': 'active',
          'planId': 'yearly',
          'planName': 'Yearly',
          'billingType': 'yearly',
          'provider': 'apple',
          'amount': 29000,
          'currency': 'usd',
          'currentPeriodEnd': '2026-12-26T05:19:34Z',
          ...extra,
        });

    test('active plan shows its renewal date', () {
      expect(
        CurrentPlanBanner.detailFor(withFields(<String, dynamic>{})),
        startsWith('Renews on Dec 26, 2026'),
      );
    });

    test('scheduled switch wins over renewal', () {
      expect(
        CurrentPlanBanner.detailFor(
          withFields(<String, dynamic>{
            'pendingPlanId': 'monthly',
            'pendingPlanName': 'Monthly',
          }),
        ),
        'Switching to Monthly on Dec 26, 2026',
      );
    });

    test('no dates → no detail line', () {
      expect(
        CurrentPlanBanner.detailFor(
          withFields(<String, dynamic>{'currentPeriodEnd': null}),
        ),
        isNull,
      );
    });
  });
}
