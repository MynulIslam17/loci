import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/data/models/busniess/my_business_list_model.dart';
import 'package:loci/data/models/subscription/checkout_response_model.dart';
import 'package:loci/data/models/subscription/my_subscription_model.dart';
import 'package:loci/data/models/subscription/plan_response_model.dart';
import 'package:loci/data/models/subscription/subscription_config_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';

/// Handles the Stripe subscription flow described in PAYMENT_FLOW.pdf:
/// config → plans → checkout → PaymentSheet → poll /subscriptions/my.
class SubscriptionController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isInitializingStripe = false;
  bool isLoadingSubscription = false;
  bool isProcessingPurchase = false;
  bool isCancelling = false;

  String? errorMessage;
  MySubscriptionModel? mySubscription;
  bool _stripeConfigured = false;
  Future<void>? _stripeInitFuture;
  String? _stripeInitError;

  bool get hasActiveSubscription => mySubscription?.isActive == true;

  @override
  void onInit() {
    super.onInit();
    // Defer until after AuthController loads the saved session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeStripe();
    });
  }

  // ── STEP 1: Initialize Stripe after login (needs auth token) ─────────────
  Future<void> initializeStripe() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) return;
    if (_stripeConfigured) return;

    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) return;

    // Reuse in-flight init so Subscribe doesn't bail out mid-request.
    _stripeInitFuture ??= _performStripeInit();
    await _stripeInitFuture;
  }

  Future<void> _performStripeInit() async {
    isInitializingStripe = true;
    _stripeInitError = null;
    update();

    try {
      final response = await _network.getRequest(url: AppUrl.subscriptionConfig);
      if (!response.isSuccess || response.body == null) {
        throw Exception(response.errorMessage ?? 'Failed to load payment config');
      }

      final config = SubscriptionConfigModel.fromJson(response.body!);
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
      isInitializingStripe = false;
      update();
    }
  }

  // ── STEP 6: Load current subscription for UI ─────────────────────────────
  Future<void> fetchMySubscription() async {
    isLoadingSubscription = true;
    errorMessage = null;
    update();

    try {
      final response = await _network.getRequest(url: AppUrl.subscriptionMy);
      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        mySubscription = data is Map<String, dynamic>
            ? MySubscriptionModel.fromJson(data)
            : null;
      } else {
        errorMessage = response.errorMessage;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingSubscription = false;
      update();
    }
  }

  // ── STEPS 3–5: Full purchase flow ───────────────────────────────────────
  Future<void> subscribeToPlan(PlanModel plan) async {
    if (isProcessingPurchase) return;

    isProcessingPurchase = true;
    update();

    try {
      await initializeStripe();

      if (!_stripeConfigured) {
        SnackbarService.error(
          _stripeInitError ??
              'Could not connect to payment service. Check your connection and try again.',
        );
        return;
      }

      final businessId = await _resolveBusinessId();
      if (businessId == null) {
        isProcessingPurchase = false;
        update();
        return;
      }

      final checkout = await _startCheckout(planId: plan.id, businessId: businessId);
      if (checkout == null) {
        isProcessingPurchase = false;
        update();
        return;
      }

      if (checkout.free) {
        SnackbarService.success('Plan activated');
        await fetchMySubscription();
        return;
      }

      if (!checkout.requiresPaymentSheet) {
        SnackbarService.error('Could not start checkout. Please try again.');
        return;
      }

      await _presentPaymentSheet(checkout);

      final activated = await _waitForActive();
      if (activated) {
        SnackbarService.success('Subscription activated');
        await fetchMySubscription();
      } else {
        SnackbarService.info(
          'Payment received — your plan should activate shortly.',
          title: 'Almost there',
        );
        await fetchMySubscription();
      }
    } on StripeException catch (e) {
      final message = e.error.localizedMessage ?? 'Payment cancelled';
      if (e.error.code != FailureCode.Canceled) {
        SnackbarService.error(message);
      }
    } catch (e) {
      SnackbarService.error(e.toString());
    } finally {
      isProcessingPurchase = false;
      update();
    }
  }

  // ── STEP 7: Cancel subscription ──────────────────────────────────────────
  Future<void> cancelSubscription() async {
    if (isCancelling) return;

    isCancelling = true;
    update();

    try {
      final response = await _network.deleteRequest(url: AppUrl.subscriptionMy);
      if (response.isSuccess) {
        final data = response.body?['data'];
        if (data is Map<String, dynamic>) {
          mySubscription = MySubscriptionModel.fromJson(data);
        } else {
          mySubscription = null;
        }

        final endDate = mySubscription?.currentPeriodEnd;
        if (endDate != null && mySubscription?.cancelAtPeriodEnd == true) {
          SnackbarService.success(
            'Your plan stays active until ${_formatDate(endDate)}.',
          );
        } else {
          SnackbarService.success('Subscription cancelled');
          mySubscription = null;
        }
      } else {
        SnackbarService.error(
          response.errorMessage ?? 'Failed to cancel subscription',
        );
      }
    } catch (e) {
      SnackbarService.error(e.toString());
    } finally {
      isCancelling = false;
      update();
    }
  }

  Future<String?> _resolveBusinessId() async {
    final response = await _network.getRequest(url: AppUrl.myBusiness);
    if (!response.isSuccess || response.body == null) {
      SnackbarService.error(
        response.errorMessage ??
            'You need a business profile before subscribing.',
      );
      return null;
    }

    final businesses = (response.body!['data'] as List<dynamic>? ?? [])
        .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (businesses.isEmpty) {
      SnackbarService.error(
        'Create or claim a business first, then come back to subscribe.',
      );
      return null;
    }

    if (businesses.length == 1) return businesses.first.id;

    final selected = await Get.dialog<BusinessModel>(
      AlertDialog(
        title: const Text('Choose a business'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
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
  }

  Future<CheckoutResponseModel?> _startCheckout({
    required String planId,
    required String businessId,
  }) async {
    final response = await _network.postRequest(
      url: AppUrl.subscriptionCheckout,
      body: {
        'planId': planId,
        'businessId': businessId,
      },
    );

    if (response.isSuccess && response.body != null) {
      return CheckoutResponseModel.fromJson(response.body!);
    }

    SnackbarService.error(response.errorMessage ?? 'Checkout failed');
    return null;
  }

  Future<void> _presentPaymentSheet(CheckoutResponseModel checkout) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'Loci',
        customerId: checkout.customerId!,
        customerEphemeralKeySecret: checkout.ephemeralKey!,
        paymentIntentClientSecret: checkout.paymentIntentClientSecret!,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  /// Stripe webhooks take 1–3 seconds — poll until status is active.
  Future<bool> _waitForActive({int attempts = 8}) async {
    for (var i = 0; i < attempts; i++) {
      final response = await _network.getRequest(url: AppUrl.subscriptionMy);
      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        if (data is Map<String, dynamic>) {
          final sub = MySubscriptionModel.fromJson(data);
          if (sub.isActive) {
            mySubscription = sub;
            update();
            return true;
          }
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
