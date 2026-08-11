import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:loci/core/services/stripe_service.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/subscription/data/models/checkout_response_model.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/models/plan_response_model.dart';
import 'package:loci/features/subscription/data/models/subscription_config_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

/// Handles the Stripe subscription flow described in PAYMENT_FLOW.pdf:
/// config → plans → checkout → PaymentSheet → poll /subscriptions/my.
class SubscriptionController extends GetxController {
  SubscriptionController(this._service);

  final SubscriptionService _service;

  final RxBool _isInitializingStripe = false.obs;
  final RxBool _isLoadingSubscription = false.obs;
  final RxBool _isProcessingPurchase = false.obs;
  final RxBool _isCancelling = false.obs;

  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<MySubscriptionModel> _mySubscription = Rxn<MySubscriptionModel>();
  bool _stripeConfigured = false;
  Future<void>? _stripeInitFuture;
  String? _stripeInitError;

  bool get isInitializingStripe => _isInitializingStripe.value;
  bool get isLoadingSubscription => _isLoadingSubscription.value;
  bool get isProcessingPurchase => _isProcessingPurchase.value;
  bool get isCancelling => _isCancelling.value;
  String? get errorMessage => _errorMessage.value;
  MySubscriptionModel? get mySubscription => _mySubscription.value;

  bool get hasActiveSubscription => mySubscription?.isActive == true;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeStripe();
    });
  }

  Future<void> initializeStripe() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) return;
    if (_stripeConfigured) return;

    final AuthController auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) return;

    _stripeInitFuture ??= _performStripeInit();
    await _stripeInitFuture;
  }

  Future<void> _performStripeInit() async {
    _isInitializingStripe.value = true;
    _stripeInitError = null;

    try {
      final SubscriptionConfigModel config = await _service.getConfig();
      if (config.publishableKey.isEmpty) {
        throw Exception('Payment service returned an invalid key');
      }

      Stripe.publishableKey = config.publishableKey;
      await Stripe.instance.applySettings();
      _stripeConfigured = true;
    } catch (e) {
      _stripeInitFuture = null;
      _stripeInitError = e.toString();
      debugPrint('Stripe init failed: $e');
    } finally {
      _isInitializingStripe.value = false;
    }
  }

  Future<void> fetchMySubscription(String businessId) async {
    _isLoadingSubscription.value = true;
    _errorMessage.value = null;

    try {
      _mySubscription.value = await _service.getMySubscription(businessId);
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingSubscription.value = false;
    }
  }

  Future<void> subscribeToPlan(PlanModel plan) async {
    if (isProcessingPurchase) return;

    _isProcessingPurchase.value = true;

    try {
      await initializeStripe();

      if (!_stripeConfigured) {
        SnackbarService.error(
          _stripeInitError ??
              'Could not connect to payment service. Check your connection and try again.',
        );
        return;
      }

      final String? businessId = await _resolveBusinessId();
      if (businessId == null) {
        _isProcessingPurchase.value = false;
        return;
      }

      final CheckoutModel checkout = await _service.checkout(
        planId: plan.id,
        businessId: businessId,
      );

      if (checkout.isFree) {
        SnackbarService.success('Plan activated');
        await fetchMySubscription(businessId);
        return;
      }

      if (!checkout.canPresentSheet) {
        SnackbarService.error('Could not start checkout. Please try again.');
        return;
      }

      await _presentPaymentSheet(checkout);

      final bool activated = await _waitForActive(businessId);
      if (activated) {
        SnackbarService.success('Subscription activated');
        await fetchMySubscription(businessId);
      } else {
        SnackbarService.info(
          'Payment received — your plan should activate shortly.',
          title: 'Almost there',
        );
        await fetchMySubscription(businessId);
      }
    } on StripeException catch (e) {
      final String message = e.error.localizedMessage ?? 'Payment cancelled';
      if (e.error.code != FailureCode.Canceled) {
        SnackbarService.error(message);
      }
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isProcessingPurchase.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    if (isCancelling) return;

    _isCancelling.value = true;

    try {
      final String? businessId = await _resolveBusinessId();
      if (businessId == null) return; // _resolveBusinessId already toasted why
      await _service.cancelSubscription(businessId);
      // Cancellation is immediate now — `/my` returns null right after, so clear
      // the plan and confirm.
      _mySubscription.value = null;
      SnackbarService.success('Subscription cancelled');
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isCancelling.value = false;
    }
  }

  Future<String?> _resolveBusinessId() async {
    try {
      final List<BusinessModel> businesses = await _service.getMyBusinesses();

      if (businesses.isEmpty) {
        SnackbarService.error(
          'Create or claim a business first, then come back to subscribe.',
        );
        return null;
      }

      if (businesses.length == 1) return businesses.first.id;

      final BusinessModel? selected = await Get.dialog<BusinessModel>(
        AlertDialog(
          title: const Text('Choose a business'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: businesses.length,
              itemBuilder: (BuildContext context, int index) {
                final BusinessModel business = businesses[index];
                return ListTile(
                  title: Text(business.name),
                  onTap: () => Get.back(result: business),
                );
              },
            ),
          ),
        ),
      );

      return selected?.id;
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
      return null;
    }
  }

  Future<void> _presentPaymentSheet(CheckoutModel checkout) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'Loci',
        customerId: checkout.customerId!,
        customerEphemeralKeySecret: checkout.ephemeralKey!,
        paymentIntentClientSecret: checkout.paymentIntentClientSecret!,
        appearance: Get.find<StripeService>().themedAppearance(),
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  Future<bool> _waitForActive(String businessId, {int attempts = 8}) async {
    for (int i = 0; i < attempts; i++) {
      try {
        final MySubscriptionModel? sub = await _service.getMySubscription(
          businessId,
        );
        if (sub?.isActive == true) {
          _mySubscription.value = sub;
          return true;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }
}
