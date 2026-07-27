import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:loci/core/services/stripe_service.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/subscription/data/models/checkout_response_model.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

/// Drives the full Stripe purchase flow (see PAYMENTS.md §9):
///   checkout → PaymentSheet → poll `GET /my` → active.
class SubscriptionCheckoutController extends GetxController {
  SubscriptionCheckoutController(this._service);

  final SubscriptionService _service;

  final Rxn<String> _processingPlanId = Rxn<String>();
  String? _businessId;
  final Rxn<MySubscriptionModel> _mySubscription = Rxn<MySubscriptionModel>();
  final RxBool _isCancelling = false.obs;
  // True until the very first `/my` fetch settles. Lets the page show a shimmer
  // instead of flashing the "no subscription" state (all cards "Subscribe", no
  // banner) before the current plan is known — subsequent refetches (poll,
  // post-purchase) don't flip this back, so they never re-shimmer.
  final RxBool _isInitialLoad = true.obs;

  String? get processingPlanId => _processingPlanId.value;
  MySubscriptionModel? get mySubscription => _mySubscription.value;
  bool get isCancelling => _isCancelling.value;
  bool get isLoadingSubscription => _isInitialLoad.value;

  bool isProcessing(String planId) => processingPlanId == planId;

  @override
  void onInit() {
    super.onInit();
    fetchMySubscription();
  }

  void _setProcessing(String? planId) {
    _processingPlanId.value = planId;
  }

  Future<void> subscribe(String planId) async {
    if (processingPlanId != null) return;
    _setProcessing(planId);

    try {
      final String? businessId = await _resolveBusinessId();
      if (businessId == null) {
        SnackbarService.error(
          'You need a business before subscribing. Please claim or create one first.',
        );
        return;
      }

      final CheckoutModel checkout = await _service.checkout(
        planId: planId,
        businessId: businessId,
      );

      if (checkout.isFree) {
        await fetchMySubscription();
        // Success shows itself: the plan card flips to "Current Plan". Only
        // speak up when the switch didn't actually take.
        final bool activated =
            mySubscription?.isActive == true && mySubscription?.amount == 0;
        if (!activated) {
          SnackbarService.error(
            'Could not switch to the Free plan. Please try again.',
          );
        }
        return;
      }

      // 2b. Downgrade to a cheaper paid plan — deferred to period end by the
      // backend (a Stripe Subscription Schedule), nothing charged now, so
      // there's no PaymentSheet to show. The current plan keeps running.
      if (checkout.scheduled) {
        // The plan card shows the "Scheduled" state — no toast needed.
        await fetchMySubscription();
        return;
      }

      // 2c. Upgrade applied immediately in place (existing Stripe subscription
      // updated, not a new one) — if Stripe could already charge the prorated
      // difference automatically, there's nothing left to confirm here.
      if (checkout.switched && !checkout.canPresentSheet) {
        // Applied in place — the plan card reflects the new plan, no toast.
        await fetchMySubscription();
        return;
      }

      if (kIsWeb) {
        SnackbarService.info(
          'Subscriptions can be purchased from the Loci mobile app (iOS/Android).',
        );
        return;
      }

      if (!checkout.canPresentSheet) {
        SnackbarService.error(
          'Payments are not available right now. Please try again later.',
        );
        return;
      }
      if (!await _ensureStripeReady()) {
        SnackbarService.error(
          'Payments are not available right now. Please try again later.',
        );
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Loci',
          customerId: checkout.customerId,
          customerEphemeralKeySecret: checkout.ephemeralKey,
          paymentIntentClientSecret: checkout.paymentIntentClientSecret,
          appearance: Get.find<StripeService>().themedAppearance(),
        ),
      );

      try {
        await Stripe.instance.presentPaymentSheet();
      } on StripeException catch (e) {
        // User dismissing the sheet is not an error — stay silent. Only a real
        // payment failure warrants a message.
        if (e.error.code != FailureCode.Canceled) {
          SnackbarService.error(
            e.error.localizedMessage ??
                'Payment failed. Please try another card.',
          );
        }
        return;
      }

      // Success reflects itself on the plan card once the backend catches up.
      await _pollForActive();
    } catch (e) {
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      _setProcessing(null);
    }
  }

  Future<bool> _pollForActive() async {
    for (int i = 0; i < 8; i++) {
      await fetchMySubscription();
      if (mySubscription?.isActive ?? false) return true;
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> fetchMySubscription() async {
    try {
      // `GET /my` is per-business now — without the id the backend 400s.
      final String? businessId = await _resolveBusinessId();
      if (businessId == null) return;
      _mySubscription.value = await _service.getMySubscription(businessId);
    } catch (_) {
      // Keep previous state on transient poll failures.
    } finally {
      // First load is done (success, no-business, or error) — reveal real UI.
      _isInitialLoad.value = false;
    }
  }

  Future<void> cancel() async {
    if (isCancelling) return;
    _isCancelling.value = true;
    try {
      final String? businessId = await _resolveBusinessId();
      if (businessId == null) {
        SnackbarService.error(
          'You need a business before managing a subscription.',
        );
        return;
      }
      await _service.cancelSubscription(businessId);
      // The banner reflects the cancellation — no toast on success.
      await fetchMySubscription();
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isCancelling.value = false;
    }
  }

  Future<String?> _resolveBusinessId() async {
    if (_businessId != null && _businessId!.isNotEmpty) return _businessId;

    try {
      final List<BusinessModel> businesses = await _service.getMyBusinesses();
      if (businesses.isEmpty) return null;
      _businessId = businesses.first.id;
      return _businessId;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _ensureStripeReady() async {
    final StripeService service = Get.find<StripeService>();
    if (!service.isReady) {
      await service.init();
    }
    return service.isReady;
  }
}
