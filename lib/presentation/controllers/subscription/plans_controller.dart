import 'package:get/get.dart';
import '../../../core/enums/billing_type_enum.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/constants/app_url.dart';
import '../../../data/models/subscription/plan_response_model.dart';

class PlansController extends GetxController {
  final NetworkCaller _networkCaller = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;

  List<PlanModel> plans = [];
  BillingType? currentType;

  // ─────────────────────────────
  // FETCH PLANS
  // ─────────────────────────────
  Future<void> fetchPlans(BillingType billingType) async {

    if(currentType==billingType &&plans.isNotEmpty)return;

    try {
      isLoading = true;
      errorMessage = null;
      update();

      final response = await _networkCaller.getRequest(
        url: "${AppUrl.subscriptionPlans}?billingType=${billingType.toJson}",
      );

      if (response.isSuccess && response.body != null) {
        final model = PlanResponseModel.fromJson(response.body!);
        plans = model.data;
      } else {
        errorMessage = response.errorMessage ?? "Failed to load plans";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }


  // ─────────────────────────────
  // REFRESH
  // ─────────────────────────────
  Future<void> refreshPlans(BillingType billingType) async {
    currentType=null;
    await fetchPlans(billingType);
  }
}