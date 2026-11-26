import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';

void main() {
  test('parses the §2.3 payload', () {
    final MySubscriptionModel m = MySubscriptionModel.fromJson(<String, dynamic>{
      'status': 'active',
      'planId': 'monthly',
      'planName': 'Monthly',
      'billingType': 'monthly',
      'provider': 'apple',
      'currentPeriodStart': '2026-11-25T10:00:00.000Z',
      'currentPeriodEnd': '2026-12-25T10:00:00.000Z',
      'cancelAtPeriodEnd': true,
      'entitlementEndsAt': '2026-12-28T10:00:00.000Z',
      'inGracePeriod': true,
      'creditsExpireAt': '2026-12-25T10:00:00.000Z',
      'heroSpotlightCredits': 70,
      'credits': <String, dynamic>{'total': 100, 'used': 30, 'remaining': 70},
    });
    expect(m.isActive, isTrue);
    expect(m.isStoreManaged, isTrue);
    expect(m.cancelAtPeriodEnd, isTrue);
    expect(m.inGracePeriod, isTrue);
    expect(m.accessEndsAt, '2026-12-28T10:00:00.000Z');
    expect(m.creditsExpireAt, '2026-12-25T10:00:00.000Z');
    expect(m.remainingCredits, 70);
    expect(m.credits!.remainingFraction, closeTo(.7, 1e-9));
  });

  test('tolerates numbers as doubles/strings and falls back to legacy credits', () {
    final MySubscriptionModel m = MySubscriptionModel.fromJson(<String, dynamic>{
      'status': 'active',
      'heroSpotlightCredits': 40.0,
      'amount': '2900',
    });
    expect(m.remainingCredits, 40);
    expect(m.amount, 2900);
    expect(m.isStoreManaged, isFalse);
    expect(m.accessEndsAt, isNull);
  });

  test('manage subscription deep links', () {
    expect(
      MySubscriptionController.manageSubscriptionUri(isIOS: true).toString(),
      'https://apps.apple.com/account/subscriptions',
    );
    expect(
      MySubscriptionController.manageSubscriptionUri(
        isIOS: false,
        productId: LociIapProducts.yearly,
      ).toString(),
      'https://play.google.com/store/account/subscriptions'
      '?sku=ui.neatboutique.jacobi.business.yearly&package=ui.neatboutique.jacobi',
    );
  });

  test('product id from plan', () {
    MySubscriptionModel plan(String id) =>
        MySubscriptionModel.fromJson(<String, dynamic>{'status': 'active', 'planId': id});
    expect(MySubscriptionController.productIdFor(plan('yearly')), LociIapProducts.yearly);
    expect(MySubscriptionController.productIdFor(plan('monthly')), LociIapProducts.monthly);
    expect(MySubscriptionController.productIdFor(null), isNull);
  });
}
