import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../data/models/routes/routes_model.dart';


class RouteListController extends GetxController {

  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  List<RouteModel> _routeList = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 10;

  String _searchQuery = '';
  Timer? _searchDebounce;


  //----getter
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<RouteModel> get routeList => _routeList;
  bool get hasMore => _hasNextPage;
  String get searchQuery => _searchQuery;

  /// Debounced search — updates the query and refetches from the API.
  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchRoutes(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }



  //--- fetch routes
  Future<void> fetchRoutes({bool isRefresh = false, String? businessId}) async {

    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _routeList.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    update();

    try {

      final url = _buildUrl(businessId: businessId);


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

  Future<void> loadMoreRoutes({String? businessId}) async {
    if (!_hasNextPage || _isPaginationLoading) return;

    _isPaginationLoading = true;
    _currentPage++;
    update();

    try {
      final url = _buildUrl(businessId: businessId);

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

/// reset the controller
  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _errorMessage = null;
    _routeList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _searchQuery = '';
    _searchDebounce?.cancel();
  }

  String _buildUrl({String? businessId}) {
    final params = <String, String>{
      'page': '$_currentPage',
      'limit': '$_limit',
    };
    if (businessId != null) params['businessId'] = businessId;
    final query = _searchQuery.trim();
    if (query.isNotEmpty) params['search'] = query;

    final qs = params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '${AppUrl.routeList}?$qs';
  }


}