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
  BillingType? currentType;

  // Billing toggle + expanded card are UI state that belongs to this screen's
  // controller so there is a single source of truth (previously duplicated in
  // the widget as local Rx values, which could drift from [currentType]).
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
    if (currentType == billingType && _plans.isNotEmpty) return;

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      _plans.assignAll(await _service.getPlans(billingType));
      currentType = billingType;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshPlans() async {
    currentType = null;
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
