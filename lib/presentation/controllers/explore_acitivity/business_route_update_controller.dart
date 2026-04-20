import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../data/models/explore_activity/route_update_request_model.dart';

class BusinessRouteUpdateController extends GetxController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> updateRoute(RouteUpdateRequest request) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().multipartRequest(
        url: AppUrl.routeDetails(request.routeId),
        method: "PATCH",
        fields: request.toFields().isNotEmpty ? request.toFields() : null ,
        files: request.toFiles(),
      );

      if (response.isSuccess) {
        _isLoading = false;
        update();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Update failed";
        _isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An unexpected error occurred: $e";
      update();
      return false;
    }
  }
}