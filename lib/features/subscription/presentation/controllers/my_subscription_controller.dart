import 'dart:io';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/subscription/presentation/subscription_messages.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';

/// "My Subscription" screen. Reads the app-wide, server-authoritative
/// [SubscriptionStatusController]; never edits the subscription locally.
class MySubscriptionController extends GetxController {
  MySubscriptionController(this._status, this._service);

  final SubscriptionStatusController _status;
  final SubscriptionService _service;

  static const String androidPackage = 'ui.neatboutique.jacobi';

  final RxBool _isOpeningStore = false.obs;
  final RxBool _isCancelling = false.obs;

  bool get isLoading => _status.isLoading.value;
  bool get hasLoaded => _status.hasLoaded.value;
  bool get showInitialShimmer => isLoading && !hasLoaded;
  bool get hasNoBusiness => _status.hasNoBusiness.value;
  bool get isOpeningStore => _isOpeningStore.value;
  bool get isCancelling => _isCancelling.value;

  /// Error of the last refresh. With a known status it's shown as a retry
  /// banner — never as the paywall.
  String? get errorMessage => _status.errorMessage.value;
  MySubscriptionModel? get subscription => _status.subscription.value;

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }

  Future<void> fetchSubscription({bool isRefresh = false}) => _status.reload();

  /// Price shown for the active plan: the store's localized price (what the
  /// user is actually billed), falling back to the server's amount only when
  /// the store product isn't loaded. Pure for testing.
  static String displayPrice(MySubscriptionModel sub, {String? storePrice}) {
    if (sub.isStoreManaged && (storePrice?.isNotEmpty ?? false)) {
      return storePrice!;
    }
    return sub.formattedAmount;
  }

  String priceFor(MySubscriptionModel sub) {
    final String? productId = productIdFor(sub);
    final String? storePrice =
        productId != null && Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>().productFor(productId)?.price
        : null;
    return displayPrice(sub, storePrice: storePrice);
  }

  /// Store product id for the current plan (used for the Play deep link).
  static String? productIdFor(MySubscriptionModel? sub) {
    // "free" plans say billingType monthly — never map them to Monthly.
    if (sub == null || sub.isFreePlan) return null;
    final String plan = '${sub.planId ?? ''} ${sub.billingType ?? ''}'
        .toLowerCase();
    if (plan.contains('year') || plan.contains('annual')) {
      return LociIapProducts.yearly;
    }
    if (plan.contains('month')) return LociIapProducts.monthly;
    return null;
  }

  /// Store product the backend says the subscription switches to at the
  /// next renewal (`pendingPlanId`), or null when no switch is pending.
  static String? pendingProductIdFor(MySubscriptionModel? sub) {
    final String plan =
        '${sub?.pendingPlanId ?? ''} ${sub?.pendingPlanName ?? ''}'
            .toLowerCase();
    if (plan.contains('year') || plan.contains('annual')) {
      return LociIapProducts.yearly;
    }
    if (plan.contains('month')) return LociIapProducts.monthly;
    return null;
  }

  static Uri manageSubscriptionUri({required bool isIOS, String? productId}) {
    if (isIOS) return Uri.parse('https://apps.apple.com/account/subscriptions');
    return Uri.https('play.google.com', '/store/account/subscriptions', {
      'sku': ?productId,
      'package': androidPackage,
    });
  }

  /// The app cannot cancel a store subscription — open the store's
  /// management page. Status refreshes when the app resumes.
  Future<void> manageSubscription() async {
    if (_isOpeningStore.value) return;
    _isOpeningStore.value = true;
    try {
      final Uri uri = manageSubscriptionUri(
        isIOS: Platform.isIOS,
        productId: productIdFor(subscription),
      );
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        SnackbarService.error(SubscriptionMessages.openStoreFailed);
      }
    } catch (e) {
      logSubscriptionError('manage', e);
      SnackbarService.error(SubscriptionMessages.openStoreFailed);
    } finally {
      _isOpeningStore.value = false;
    }
  }

  /// Legacy Stripe plans only. Never called for `apple` / `google`
  /// (the server answers `STORE_CANCEL_REQUIRED`).
  Future<void> cancelLegacySubscription() async {
    final String? businessId = _status.businessId;
    if (_isCancelling.value || businessId == null) return;
    if (subscription?.isStoreManaged ?? true) return manageSubscription();
    _isCancelling.value = true;
    try {
      await _service.cancelSubscription(businessId);
    } catch (e) {
      logSubscriptionError('cancel', e);
      SnackbarService.error(
        friendlySubscriptionError(
          e,
          fallback: SubscriptionMessages.cancelFailed,
        ),
      );
    } finally {
      _isCancelling.value = false;
      // Don't clear locally — the server decides what remains.
      await _status.reload();
    }
  }
}
