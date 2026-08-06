import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/routes/data/models/route_list_model.dart';
import 'package:loci/features/routes/domain/services/routes_service.dart';

class RouteListController extends GetxController {
  RouteListController(this._service);

  final RoutesService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<RouteModel> _routeList = <RouteModel>[].obs;
  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 5;

  String _searchQuery = '';
  Timer? _searchDebounce;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  bool get isPaginationLoading => _fetch.loadingMore.value;
  String? get errorMessage => _errorMessage.value;
  List<RouteModel> get routeList => _routeList;
  bool get hasMore => _hasNextPage;
  String get searchQuery => _searchQuery;

  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchRoutes(isSearch: true);
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _searchDebounce?.cancel();
    fetchRoutes(isSearch: true);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchRoutes({
    bool isRefresh = false,
    bool isSearch = false,
    String? businessId,
  }) async {
    if (isRefresh || isSearch) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    if (isSearch) {
      _fetch.initialLoading.value = true;
      _fetch.refreshing.value = false;
      _fetch.hasFetched.value = false;
    } else {
      _fetch.beginFirstPage(isRefresh: isRefresh);
    }
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
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> loadMoreRoutes({String? businessId}) async {
    if (!_hasNextPage ||
        isPaginationLoading ||
        isInitialLoading ||
        isRefreshing) {
      return;
    }

    _fetch.beginLoadMore();
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
      _fetch.endLoadMore();
    }
  }

  void reset() {
    _fetch.reset();
    _errorMessage.value = null;
    _routeList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _searchQuery = '';
    _searchDebounce?.cancel();
  }
}
