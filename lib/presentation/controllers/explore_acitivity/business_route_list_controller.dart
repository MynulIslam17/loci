import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../data/models/routes/routes_model.dart';


class BusinessRouteListController extends GetxController {
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  List<RouteModel> _routeList = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 2;

  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<RouteModel> get routeList => _routeList;
  bool get hasMore => _hasNextPage;

  Future<void> fetchRoutes({bool isRefresh = false, required String businessId}) async {
    if (_isLoading) return; // Prevent multiple simultaneous refreshes

    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;

    }

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final url = '${AppUrl.routeList}?page=$_currentPage&limit=$_limit&businessId=$businessId';
      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = RouteResponseModel.fromJson(response.body!);

        if (isRefresh) {
          _routeList = model.routes; // Overwrite the list
        } else {
          _routeList.addAll(model.routes);
        }

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

  Future<void> loadMoreRoutes({required String? businessId}) async {
    // IMPORTANT: Added _isLoading here to block pagination during raffles main refresh
    if (!_hasNextPage || _isPaginationLoading || _isLoading) return;

    _isPaginationLoading = true;
    _currentPage++;
    update();

    try {
      final url = '${AppUrl.routeList}?page=$_currentPage&limit=$_limit&businessId=$businessId';
      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = RouteResponseModel.fromJson(response.body!);
        _routeList.addAll(model.routes);
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _currentPage--; // Revert page number on failure
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = 'Pagination error: $e';
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _errorMessage = null;
    _routeList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    update();
  }
}