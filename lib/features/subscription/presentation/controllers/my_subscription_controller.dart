import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

/// Read-only view of the user's current subscription (`GET /subscriptions/my`)
/// for the "My Subscription" screen, plus cancellation. Intentionally light —
/// it does not touch Stripe init (that belongs to the purchase flow).
class MySubscriptionController extends GetxController {
  MySubscriptionController(this._service);

  final SubscriptionService _service;

  final _isLoading = false.obs;
  final _isCancelling = false.obs;
  final _errorMessage = RxnString();
  final _subscription = Rxn<MySubscriptionModel>();

  bool get isLoading => _isLoading.value;
  bool get isCancelling => _isCancelling.value;
  String? get errorMessage => _errorMessage.value;
  MySubscriptionModel? get subscription => _subscription.value;

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }

  Future<void> fetchSubscription() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    try {
      _subscription.value = await _service.getMySubscription();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    if (_isCancelling.value) return;
    _isCancelling.value = true;
    try {
      final updated = await _service.cancelSubscription();
      if (updated != null && updated.cancelAtPeriodEnd) {
        _subscription.value = updated;
        SnackbarService.success('Your plan stays active until it ends.');
      } else {
        _subscription.value = null;
        SnackbarService.success('Subscription cancelled');
      }
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isCancelling.value = false;
    }
  }
}
