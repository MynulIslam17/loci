import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/repositories/subscription_repository.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_selection_view.dart';

/// Exactly what the backend returned for a newly approved owner.
const Map<String, dynamic> freeRecord = <String, dynamic>{
  '_id': '6b07f69328c77a5baee176b9',
  'planId': 'free',
  'planName': 'Free',
  'billingType': 'monthly',
  'amount': 0,
  'currency': 'usd',
  'heroSpotlightCredits': 0,
  'provider': 'stripe',
  'stripeSubscriptionId': null,
  'status': 'active',
  'currentPeriodStart': '2026-11-26T09:06:27.931Z',
  'currentPeriodEnd': null,
  'credits': <String, dynamic>{'total': 0, 'used': 0, 'remaining': 0},
};

const Map<String, dynamic> appleMonthly = <String, dynamic>{
  'planId': 'monthly',
  'planName': 'Monthly',
  'billingType': 'monthly',
  'amount': 2900,
  'currency': 'usd',
  'provider': 'apple',
  'status': 'active',
  'storeProductId': 'ui.neatboutique.jacobi.business.monthly',
};

class FakeRepository implements SubscriptionRepository {
  FakeRepository(this.data);
  final Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> getMySubscription(String businessId) async =>
      <String, dynamic>{'success': true, 'data': data};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Free placeholder record', () {
    test('is recognised as a free plan', () {
      expect(MySubscriptionModel.fromJson(freeRecord).isFreePlan, isTrue);
      expect(MySubscriptionModel.fromJson(appleMonthly).isFreePlan, isFalse);
    });

    test('service reports no paid subscription', () async {
      final SubscriptionService service = SubscriptionService(
        FakeRepository(freeRecord),
      );
      expect(await service.getMySubscription('b1'), isNull);
    });

    test('a real subscription is still returned', () async {
      final SubscriptionService service = SubscriptionService(
        FakeRepository(appleMonthly),
      );
      final MySubscriptionModel? sub = await service.getMySubscription('b1');
      expect(sub?.planName, 'Monthly');
    });

    test(
      '"billingType: monthly" on Free never maps to the Monthly product',
      () {
        final MySubscriptionModel free = MySubscriptionModel.fromJson(
          freeRecord,
        );
        expect(MySubscriptionController.productIdFor(free), isNull);
        expect(
          MySubscriptionController.productIdFor(
            MySubscriptionModel.fromJson(appleMonthly),
          ),
          LociIapProducts.monthly,
        );
      },
    );

    test('Monthly stays purchasable for a Free owner', () {
      final ({String label, bool enabled}) s = planButtonState(
        selectedName: 'Monthly',
        selectedProductId: LociIapProducts.monthly,
        selectedIsPaid: true,
        current: null, // what the service now returns for Free
      );
      expect(s.label, 'Continue with Monthly');
      expect(s.enabled, isTrue);
    });
  });
}
