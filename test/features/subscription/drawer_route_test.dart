import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/main_nav/presentation/widgets/app_navigation_drawer.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/routes/app_routes.dart';

import 'fakes.dart';

void main() {
  SubscriptionStatusController status() => SubscriptionStatusController(
    FakeSubscriptionService(),
    canAccess: () => false,
    observeLifecycle: false,
  );

  test('subscriber opens My Subscription', () {
    final SubscriptionStatusController s = status();
    s.subscription.value = activeSubscription();
    expect(subscriptionRouteFor(s), AppRoutes.mySubscription);
  });

  test('free plan opens the plans screen', () {
    expect(subscriptionRouteFor(status()), AppRoutes.subscription);
  });

  test('no status controller opens the plans screen', () {
    expect(subscriptionRouteFor(null), AppRoutes.subscription);
  });
}
