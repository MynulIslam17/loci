import 'package:get/get.dart';
import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/features/routes/data/models/route_details_model.dart';
import 'package:loci/features/routes/domain/services/routes_service.dart';

class RouteDetailsController extends GetxController {
  RouteDetailsController(this._service);

  final RoutesService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<RouteDetails> _routeDetails = Rxn<RouteDetails>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  RouteDetails? get routeDetails => _routeDetails.value;

  /// Fetch route details by route ID
  Future<void> fetchRouteDetails(String routeId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      _routeDetails.value = await _service.getRouteDetails(routeId);
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  /// update check-in status locally
  void updateCheckInStatus(CheckInStatus status) {
    final current = _routeDetails.value;
    if (current == null) return;

    _routeDetails.value = current.copyWith(myCheckInStatus: status);
  }
}
