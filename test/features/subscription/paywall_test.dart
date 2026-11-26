import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/upgrade_required_sheet.dart';

import 'fakes.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    SnackbarService.errorInterceptor = UpgradeRequiredSheet.maybeIntercept;
  });
  tearDown(() {
    SnackbarService.errorInterceptor = null;
    Get.reset();
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    const GetMaterialApp(home: Scaffold(body: Text('Home'))),
  );

  test('codes map to sheets (§8)', () {
    expect(
      UpgradeRequiredSheet.kindForCode('SUBSCRIPTION_REQUIRED'),
      UpgradeSheetKind.paywall,
    );
    expect(
      UpgradeRequiredSheet.kindForCode('INSUFFICIENT_SPOTLIGHT_CREDITS'),
      UpgradeSheetKind.credits,
    );
    expect(UpgradeRequiredSheet.kindForCode('BUSINESS_ACCESS_DENIED'), isNull);
    expect(UpgradeRequiredSheet.kindForCode(null), isNull);
  });

  testWidgets('SUBSCRIPTION_REQUIRED code opens the paywall; the follow-up snackbar is swallowed', (tester) async {
    await pumpApp(tester);
    UpgradeRequiredSheet.handleErrorCode(
      403,
      'SUBSCRIPTION_REQUIRED',
      'An active subscription is required for this action.',
    );
    await tester.pumpAndSettle();
    expect(find.text('Upgrade to unlock this'), findsOneWidget);
    expect(UpgradeRequiredSheet.maybeIntercept('An active subscription is required for this action.'), isTrue);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();
  });

  testWidgets('INSUFFICIENT_SPOTLIGHT_CREDITS opens the credits sheet with the balance', (tester) async {
    final FakeSubscriptionService service = FakeSubscriptionService()
      ..subscriptionResult = MySubscriptionModel.fromJson(<String, dynamic>{
        'status': 'active',
        'creditsExpireAt': '2026-12-25T10:00:00.000Z',
        'credits': <String, dynamic>{'total': 100, 'used': 95, 'remaining': 5},
      });
    Get.put(SubscriptionStatusController(
      service,
      canAccess: () => true,
      observeLifecycle: false,
    ));
    await pumpApp(tester);
    UpgradeRequiredSheet.handleErrorCode(
      403,
      'INSUFFICIENT_SPOTLIGHT_CREDITS',
      'Insufficient Spotlight credits.',
    );
    await tester.pumpAndSettle();
    expect(find.text('Not enough Spotlight credits'), findsOneWidget);
    expect(find.textContaining('You need 10 credits, you have 5.'), findsOneWidget);
    expect(find.textContaining('Credits reset on Dec 25, 2026'), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();
  });

  testWidgets('BUSINESS_ACCESS_DENIED never opens the paywall, even if the text mentions a plan', (tester) async {
    await pumpApp(tester);
    const String msg = "You don't own this business's plan";
    UpgradeRequiredSheet.handleErrorCode(403, 'BUSINESS_ACCESS_DENIED', msg);
    expect(UpgradeRequiredSheet.maybeIntercept(msg), isFalse);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  for (final bool warning in <bool>[false, true]) {
    testWidgets('legacy text fallback: ${warning ? 'warning' : 'error'} opens the paywall', (tester) async {
      await pumpApp(tester);
      // Let the dedupe window from earlier tests lapse.
      await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 3)));
      if (warning) {
        SnackbarService.warning('An active subscription is required for this action.');
      } else {
        SnackbarService.error('Your plan does not include raffles. Upgrade to continue.');
      }
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      Get.back();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('ordinary authorization failure does not open paywall', (tester) async {
    await pumpApp(tester);
    expect(UpgradeRequiredSheet.maybeIntercept('You do not have permission.'), isFalse);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  test('credits copy', () {
    final DateFormat f = DateFormat('MMM d, yyyy');
    expect(
      UpgradeRequiredSheet.creditsMessage(null, format: f),
      'Each Spotlight ad costs 10 credits.',
    );
    expect(
      UpgradeRequiredSheet.creditsMessage(activeSubscription(remaining: 3), format: f),
      'You need 10 credits, you have 3.',
    );
  });
}
