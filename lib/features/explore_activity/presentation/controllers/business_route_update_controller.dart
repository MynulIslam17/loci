import 'package:get/get.dart';
import 'package:loci/features/explore_activity/data/models/route_update_request_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessRouteUpdateController extends GetxController {
  BusinessRouteUpdateController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  Future<bool> updateRoute(RouteUpdateRequest request) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await _service.updateRoute(request);
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }
}
