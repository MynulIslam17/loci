import 'package:get/get.dart';
import 'package:loci/features/routes/data/models/route_details_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessRouteDetailsController extends GetxController {
  BusinessRouteDetailsController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<RouteDetails> routeDetails = Rxn<RouteDetails>();

  Future<void> fetchRouteDetails(String routeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      routeDetails.value = await _service.getRouteDetails(routeId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
