import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../data/models/routes/routes_model.dart';


class RouteListController extends GetxController {
  String? _businessId; //optional variable used for business owner
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  List<RouteModel> _routeList = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 10;


  //----getter
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<RouteModel> get routeList => _routeList;

  @override
  void onInit() {
    super.onInit();
    fetchRoutes();
  }


  //--- fetch routes
  Future<void> fetchRoutes({bool isRefresh = false}) async {
    _businessId = _businessId;
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _routeList.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    update();

    try {

      final url = _businessId != null
          ? '${AppUrl.routeList}?page=$_currentPage&limit=$_limit&businessId=$_businessId'
          : '${AppUrl.routeList}?page=$_currentPage&limit=$_limit';


      final NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(
        url: url,
      );

      if (response.isSuccess && response.body != null) {
        final model = RouteResponseModel.fromJson(response.body!);
        _routeList = model.routes;
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load routes';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      update();
    }
  }

  ///  Load next page for pagination

  Future<void> loadMoreRoutes() async {
    if (!_hasNextPage || _isPaginationLoading) return;

    _isPaginationLoading = true;
    _currentPage++;
    update();

    try {
      final url = _businessId != null
          ? '${AppUrl.routeList}?page=$_currentPage&limit=$_limit&businessId=$_businessId'
          : '${AppUrl.routeList}?page=$_currentPage&limit=$_limit';

      final NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(
        url:url,
      );

      if (response.isSuccess && response.body != null) {
        final model = RouteResponseModel.fromJson(response.body!);
        _routeList.addAll(model.routes);
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _currentPage--;
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = 'Pagination error: $e';
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }
}