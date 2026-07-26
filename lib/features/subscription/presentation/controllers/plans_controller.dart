import 'package:get/get.dart';
import 'package:loci/core/enums/billing_type_enum.dart';
import 'package:loci/features/subscription/data/models/plan_response_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

class PlansController extends GetxController {
  PlansController(this._service);

  final SubscriptionService _service;

  final RxBool _isLoading = false.obs;
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

  bool get isLoading => _isLoading.value;
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

  Future<void> fetchPlans(BillingType billingType) async {
    // Serve from cache instantly — no loader, no refetch on tab switch.
    final List<PlanModel>? cached = _cache[billingType];
    if (cached != null) {
      _errorMessage.value = null;
      _plans.assignAll(cached);
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final List<PlanModel> result = await _service.getPlans(billingType);
      _cache[billingType] = result;
      _plans.assignAll(result);
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshPlans() async {
    _cache.clear();
    await fetchPlans(_selectedType);
  }

  /// Switches the billing period. No-op when already selected so the toggle
  /// animation and plan reload only fire on a real change.
  void selectBilling(bool monthly) {
    if (_isMonthly.value == monthly) return;
    _isMonthly.value = monthly;
    _expandedIndex.value = null; // collapse any open card on switch
    fetchPlans(_selectedType);
  }

  void toggleExpanded(int index) {
    _expandedIndex.value = _expandedIndex.value == index ? null : index;
  }
}
