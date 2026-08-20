import 'package:get/get.dart';
import 'package:loci/core/enums/billing_type_enum.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/subscription/data/models/plan_response_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

class PlansController extends GetxController {
  PlansController(this._service);

  final SubscriptionService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<PlanModel> _plans = <PlanModel>[].obs;

  // Plans cached per billing type, so switching Monthly <-> One-time reuses
  // what was already fetched instead of hitting the network (and flashing the
  // shimmer) on every toggle.
  final Map<BillingType, List<PlanModel>> _cache =
      <BillingType, List<PlanModel>>{};

  // Billing toggle + expanded card are UI state that belongs to this screen's
  // controller so there is a single source of truth (previously duplicated in
  // the widget as local Rx values, which could drift from the fetched type).
  final RxBool _isMonthly = true.obs;
  final RxnInt _expandedIndex = RxnInt();

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  String? get errorMessage => _errorMessage.value;
  List<PlanModel> get plans => _plans;
  bool get isMonthly => _isMonthly.value;
  int? get expandedIndex => _expandedIndex.value;

  BillingType get _selectedType =>
      _isMonthly.value ? BillingType.monthly : BillingType.oneTime;

  @override
  void onInit() {
    super.onInit();
    fetchPlans(_selectedType);
  }

  Future<void> fetchPlans(BillingType billingType, {bool isRefresh = false}) async {
    // Serve from cache instantly — no loader, no refetch on tab switch.
    final List<PlanModel>? cached = _cache[billingType];
    if (cached != null && !isRefresh) {
      _errorMessage.value = null;
      _plans.assignAll(cached);
      return;
    }

    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;

    try {
      final List<PlanModel> result = await _service.getPlans(billingType);
      _cache[billingType] = result;
      _plans.assignAll(result);
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> refreshPlans() async {
    _cache.clear();
    await fetchPlans(_selectedType, isRefresh: true);
  }

  /// Switches the billing period. No-op when already selected so the toggle
  /// animation and plan reload only fire on a real change.
  void selectBilling(bool monthly) {
    if (_isMonthly.value == monthly) return;
    _isMonthly.value = monthly;
    _expandedIndex.value = null; // collapse any open card on switch
    fetchPlans(_selectedType);
  }

  /// Resets the billing toggle back to Monthly (the first tab) and collapses cards.
  /// Called whenever the Subscription screen opens so previous state is not retained.
  void resetToMonthly() {
    _isMonthly.value = true;
    _expandedIndex.value = null;
    fetchPlans(BillingType.monthly);
  }

  void toggleExpanded(int index) {
    _expandedIndex.value = _expandedIndex.value == index ? null : index;
  }
}
