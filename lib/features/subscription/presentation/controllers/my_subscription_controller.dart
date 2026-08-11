import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

/// Read-only view of the user's current subscription (`GET /subscriptions/my`)
/// for the "My Subscription" screen, plus cancellation. Intentionally light —
/// it does not touch Stripe init (that belongs to the purchase flow).
class MySubscriptionController extends GetxController {
  MySubscriptionController(this._service);

  final SubscriptionService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final RxBool _isCancelling = false.obs;
  final RxnString _errorMessage = RxnString();
  final Rxn<MySubscriptionModel> _subscription = Rxn<MySubscriptionModel>();

  // Subscriptions are per-business; both `GET /my` and `DELETE /my` now need
  // it. This screen isn't scoped to a specific business, so we act on the
  // caller's first business — the same one checkout defaults to.
  String? _businessId;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  bool get isCancelling => _isCancelling.value;
  String? get errorMessage => _errorMessage.value;
  MySubscriptionModel? get subscription => _subscription.value;

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }

  Future<void> fetchSubscription({bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;

    try {
      final String? businessId = await _resolveBusinessId();
      if (businessId == null) {
        _errorMessage.value =
            'You need a business before viewing a subscription.';
        _fetch.endFirstPage();
        return;
      }
      _subscription.value = await _service.getMySubscription(businessId);
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> cancelSubscription() async {
    if (_isCancelling.value) return;
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
      // Cancellation is immediate — `/my` now returns null right after, so drop
      // the plan and let the screen fall back to the "no subscription" state.
      _subscription.value = null;
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
}
