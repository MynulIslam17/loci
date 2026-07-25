import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:loci/core/services/stripe_service.dart';
import 'package:loci/core/utils/show_snackbar.dart';
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

  String? get processingPlanId => _processingPlanId.value;
  MySubscriptionModel? get mySubscription => _mySubscription.value;
  bool get isCancelling => _isCancelling.value;

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
      final businessId = await _resolveBusinessId();
      if (businessId == null) {
        SnackbarService.error(
          'You need a business before subscribing. Please claim or create one first.',
        );
        return;
      }

      final checkout = await _service.checkout(
        planId: planId,
        businessId: businessId,
      );

      if (checkout.isFree) {
        await fetchMySubscription();
        if (mySubscription?.isActive == true && mySubscription?.amount == 0) {
          SnackbarService.success('Plan activated.');
        } else {
          SnackbarService.error(
            'Could not switch to the Free plan. Please try again.',
          );
        }
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
        final msg = e.error.localizedMessage;
        if (e.error.code == FailureCode.Canceled) {
          SnackbarService.info(msg ?? 'Payment cancelled.');
        } else {
          SnackbarService.error(
            msg ?? 'Payment failed. Please try another card.',
          );
        }
        return;
      }

      final active = await _pollForActive();
      if (active) {
        SnackbarService.success('Subscription active. Enjoy your plan!');
      } else {
        SnackbarService.info(
          'Payment received — activating shortly. We\'ll update it soon.',
        );
      }
    } catch (e) {
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      _setProcessing(null);
    }
  }

  Future<bool> _pollForActive() async {
    for (var i = 0; i < 8; i++) {
      await fetchMySubscription();
      if (mySubscription?.isActive ?? false) return true;
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> fetchMySubscription() async {
    try {
      _mySubscription.value = await _service.getMySubscription();
    } catch (_) {
      // Keep previous state on transient poll failures.
    }
  }

  Future<void> cancel() async {
    if (isCancelling) return;
    _isCancelling.value = true;
    try {
      await _service.cancelSubscription();
      await fetchMySubscription();
      SnackbarService.success('Subscription cancelled.');
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isCancelling.value = false;
    }
  }

  Future<String?> _resolveBusinessId() async {
    if (_businessId != null && _businessId!.isNotEmpty) return _businessId;

    try {
      final businesses = await _service.getMyBusinesses();
      if (businesses.isEmpty) return null;
      _businessId = businesses.first.id;
      return _businessId;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _ensureStripeReady() async {
    final service = Get.find<StripeService>();
    if (!service.isReady) {
      await service.init();
    }
    return service.isReady;
  }
}
