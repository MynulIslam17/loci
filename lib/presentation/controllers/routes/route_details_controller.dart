import 'package:get/get.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../data/models/routes/route_details_model.dart';

class RouteDetailsController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  RouteDetails? _routeDetails;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RouteDetails? get routeDetails => _routeDetails;

  /// Fetch route details by route ID
  Future<void> fetchRouteDetails(String routeId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      final NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrl.routeDetails(routeId));

      if (response.isSuccess && response.body != null) {

        // The API response has `data` inside
        final data = response.body!['data'];

        if (data != null) {

          _routeDetails = RouteDetails.fromJson(data);
        } else {
          _errorMessage = 'No route data found';
        }
      } else {
        _errorMessage =
            response.errorMessage ?? 'Failed to fetch route details';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }
}
