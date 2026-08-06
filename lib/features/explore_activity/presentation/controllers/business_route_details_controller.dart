import 'package:get/get.dart';
import 'package:loci/features/routes/data/models/route_detail_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessRouteDetailsController extends GetxController {
  BusinessRouteDetailsController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<RouteDetails> routeDetails = Rxn<RouteDetails>();

  String screenTitle = '';
  String _routeId = '';
  String _businessId = '';

  Future<void> loadFromRouteArguments() async {
    final args = Get.arguments as Map<String, dynamic>?;
    screenTitle = args?['routeName']?.toString() ?? '';
    _routeId = args?['routeId']?.toString() ?? '';
    _businessId = args?['businessId']?.toString() ?? '';
    await fetchRouteDetails(
      _routeId,
      businessId: _businessId.isNotEmpty ? _businessId : null,
    );
  }

  Future<void> retryLoad() => fetchRouteDetails(
        _routeId,
        businessId: _businessId.isNotEmpty ? _businessId : null,
      );

  Future<void> refreshDetails() => fetchRouteDetails(
        _routeId,
        businessId: _businessId.isNotEmpty ? _businessId : null,
        silent: true,
      );

  Future<void> fetchRouteDetails(
    String routeId, {
    String? businessId,
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        isLoading.value = true;
        routeDetails.value = null;
      }
      errorMessage.value = null;

      routeDetails.value = await _service.getRouteDetails(
        routeId,
        businessId: businessId,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }
}
