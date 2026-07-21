import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/services/stripe_service.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../data/models/busniess/my_business_list_model.dart';
import '../../../data/models/subscription/checkout_response_model.dart';
import '../../../data/models/subscription/my_subscription_model.dart';

/// Drives the full Stripe purchase flow (see PAYMENTS.md §9):
///   checkout → PaymentSheet → poll `GET /my` → active.
///
/// Two rules the flow enforces:
///  1. Card data never touches us — Stripe's PaymentSheet collects it.
///  2. Payment success ≠ active yet — activation lands ~1–3s later via a
///     backend webhook, so we poll `GET /my` instead of assuming `active`.
class SubscriptionCheckoutController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  /// The plan id currently being processed (drives per-card button spinners).
  String? processingPlanId;

  /// Cached businessId of the caller's own business (resolved once).
  String? _businessId;

  /// Latest known subscription state (null = no active subscription).
  MySubscriptionModel? mySubscription;

  bool isCancelling = false;

  bool isProcessing(String planId) => processingPlanId == planId;

  void _setProcessing(String? planId) {
    processingPlanId = planId;
    update();
  }

  // ─────────────────────────────────────────────────────────────
  // MAIN: subscribe / buy a plan
  // ─────────────────────────────────────────────────────────────
  Future<void> subscribe(String planId) async {
    if (processingPlanId != null) return; // guard against double taps
    _setProcessing(planId);

    try {
      final businessId = await _resolveBusinessId();
      if (businessId == null) {
        SnackbarService.error(
          'You need a business before subscribing. Please claim or create one first.',
        );
        return;
      }

      // 1. Start checkout — backend creates the Customer + Subscription/PI.
      final response = await _network.postRequest(
        url: AppUrl.subscriptionCheckout,
        body: {'planId': planId, 'businessId': businessId},
      );

      if (!response.isSuccess || response.body == null) {
        SnackbarService.error(response.errorMessage ?? 'Could not start checkout.');
        return;
      }

      final checkout = CheckoutModel.fromJson(
        (response.body!['data'] as Map<String, dynamic>?) ?? {},
      );

      // 2a. Free plan — already active, no payment UI. Verify the refreshed
      // subscription actually reflects Free before celebrating — the backend
      // used to silently no-op this when another plan was already active.
      if (checkout.isFree) {
        await fetchMySubscription();
        if (mySubscription?.isActive == true && mySubscription?.amount == 0) {
          SnackbarService.success('Plan activated.');
        } else {
          SnackbarService.error('Could not switch to the Free plan. Please try again.');
        }
        return;
      }

      // Paid plans use Stripe's native PaymentSheet, which flutter_stripe only
      // implements on Android/iOS. On web there is no plugin, so surface a clear
      // message (rather than the misleading generic "not available" one) and stop.
      if (kIsWeb) {
        SnackbarService.info(
          'Subscriptions can be purchased from the Loci mobile app (iOS/Android).',
        );
        return;
      }

      // 2b. Paid plan — make sure Stripe is initialized, then present the sheet.
      if (!checkout.canPresentSheet) {
        SnackbarService.error('Payments are not available right now. Please try again later.');
        return;
      }
      if (!await _ensureStripeReady()) {
        SnackbarService.error('Payments are not available right now. Please try again later.');
        return;
      }

      // 3. Present Stripe's native PaymentSheet (handles card + 3-D Secure).
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Loci',
          customerId: checkout.customerId,
          customerEphemeralKeySecret: checkout.ephemeralKey,
          paymentIntentClientSecret: checkout.paymentIntentClientSecret,
          // Match the sheet (and its cancel dialog) to the app theme.
          appearance: Get.find<StripeService>().themedAppearance(),
        ),
      );

      try {
        await Stripe.instance.presentPaymentSheet(); // throws on cancel/decline
      } on StripeException catch (e) {
        // User cancelled or the card was declined — nothing was charged.
        final msg = e.error.localizedMessage;
        if (e.error.code == FailureCode.Canceled) {
          SnackbarService.info(msg ?? 'Payment cancelled.');
        } else {
          SnackbarService.error(msg ?? 'Payment failed. Please try another card.');
        }
        return;
      }

      // 4. Payment confirmed on Stripe's side — activation is async via webhook.
      final active = await _pollForActive();
      if (active) {
        SnackbarService.success('Subscription active. Enjoy your plan!');
      } else {
        SnackbarService.info('Payment received — activating shortly. We\'ll update it soon.');
      }
    } catch (e) {
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      _setProcessing(null);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Poll GET /my until status == active (webhook lag, ~1–3s)
  // ─────────────────────────────────────────────────────────────
  Future<bool> _pollForActive() async {
    for (var i = 0; i < 8; i++) {
      await fetchMySubscription();
      if (mySubscription?.isActive ?? false) return true;
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // GET current subscription
  // ─────────────────────────────────────────────────────────────
  Future<void> fetchMySubscription() async {
    final response = await _network.getRequest(url: AppUrl.mySubscription);
    if (response.isSuccess) {
      final data = response.body?['data'];
      mySubscription = data is Map<String, dynamic>
          ? MySubscriptionModel.fromJson(data)
          : null;
      update();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Cancel current subscription (DELETE /my)
  // ─────────────────────────────────────────────────────────────
  Future<void> cancel() async {
    if (isCancelling) return;
    isCancelling = true;
    update();
    try {
      final response = await _network.deleteRequest(url: AppUrl.mySubscription);
      if (response.isSuccess) {
        await fetchMySubscription();
        SnackbarService.success('Subscription cancelled.');
      } else {
        SnackbarService.error(response.errorMessage ?? 'Could not cancel subscription.');
      }
    } finally {
      isCancelling = false;
      update();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  /// Resolves the caller's own businessId via `GET /businesses/me` (cached).
  Future<String?> _resolveBusinessId() async {
    if (_businessId != null && _businessId!.isNotEmpty) return _businessId;

    final response = await _network.getRequest(url: AppUrl.myBusiness);
    if (!response.isSuccess || response.body == null) return null;

    final businesses = MyBusinessResponseModel.fromJson(response.body!).data;
    if (businesses.isEmpty) return null;

    _businessId = businesses.first.id;
    return _businessId;
  }

  /// Ensures the Stripe publishable key is loaded before opening PaymentSheet.
  Future<bool> _ensureStripeReady() async {
    final service = Get.find<StripeService>();
    if (!service.isReady) {
      await service.init();
    }
    return service.isReady;
  }
}
