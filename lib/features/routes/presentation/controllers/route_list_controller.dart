import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/features/routes/data/models/route_list_model.dart';
import 'package:loci/features/routes/domain/services/routes_service.dart';

class RouteListController extends GetxController {
  RouteListController(this._service);

  final RoutesService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isPaginationLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<RouteModel> _routeList = <RouteModel>[].obs;
  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 10;

  String _searchQuery = '';
  Timer? _searchDebounce;

  bool get isLoading => _isLoading.value;
  bool get isPaginationLoading => _isPaginationLoading.value;
  String? get errorMessage => _errorMessage.value;
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

  Future<void> fetchRoutes({bool isRefresh = false, String? businessId}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _routeList.clear();
    }

    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      final model = await _service.getRoutes(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery,
      );
      _routeList.assignAll(model.routes);
      _hasNextPage = model.meta.hasNextPage;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load next page for pagination
  Future<void> loadMoreRoutes({String? businessId}) async {
    if (!_hasNextPage || _isPaginationLoading.value) return;

    _isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.getRoutes(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery,
      );
      _routeList.addAll(model.routes);
      _hasNextPage = model.meta.hasNextPage;
    } catch (e) {
      _currentPage--;
      _errorMessage.value = 'Pagination error: $e';
    } finally {
      _isPaginationLoading.value = false;
    }
  }

  /// reset the controller
  void reset() {
    _isLoading.value = false;
    _isPaginationLoading.value = false;
    _errorMessage.value = null;
    _routeList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _searchQuery = '';
    _searchDebounce?.cancel();
  }
}
