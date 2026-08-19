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
  final List<RouteModel> _unfilteredRoutes = <RouteModel>[];
  bool _unfilteredHasNextPage = true;

  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 20;

  String _searchQuery = '';
  Timer? _searchDebounce;
  int _searchSeq = 0;
  final RxBool isSearching = false.obs;

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
    if (query == _searchQuery) return;
    final hadSearch = _searchQuery.trim().isNotEmpty;
    _searchQuery = query;
    final seq = ++_searchSeq;
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      if (hadSearch) {
        _restoreUnfilteredList(sequenceToken: seq);
      }
    } else {
      isSearching.value = true;
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        fetchRoutes(isSearch: true, sequenceToken: seq);
      });
    }
  }

  void submitSearch(String query) {
    _searchDebounce?.cancel();
    if (query.trim() == _searchQuery && query.trim().isNotEmpty) return;
    _searchQuery = query;
    final seq = ++_searchSeq;
    if (query.trim().isEmpty) {
      _restoreUnfilteredList(sequenceToken: seq);
    } else {
      isSearching.value = true;
      fetchRoutes(isSearch: true, sequenceToken: seq);
    }
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return; // Do not refetch if already empty
    _searchQuery = '';
    _searchDebounce?.cancel();
    final seq = ++_searchSeq;
    _restoreUnfilteredList(sequenceToken: seq);
  }

  void _restoreUnfilteredList({int? sequenceToken}) {
    if (_unfilteredRoutes.isNotEmpty) {
      _routeList.assignAll(_unfilteredRoutes);
      _hasNextPage = _unfilteredHasNextPage;
      isSearching.value = false;
      _errorMessage.value = null;
    } else {
      fetchRoutes(isSearch: true, sequenceToken: sequenceToken);
    }
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
    int? sequenceToken,
  }) async {
    final currentSeq = sequenceToken ?? ++_searchSeq;

    if (isRefresh || isSearch) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    if (isSearch) {
      isSearching.value = true;
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

      // Discard stale out-of-order response
      if (currentSeq != _searchSeq) return;

      _routeList.assignAll(model.routes);
      _hasNextPage = model.meta.hasNextPage;
      _fetch.endFirstPage();

      if (_searchQuery.isEmpty && !isSearch) {
        _unfilteredRoutes.assignAll(model.routes);
        _unfilteredHasNextPage = model.meta.hasNextPage;
      }
    } catch (e) {
      if (currentSeq != _searchSeq) return;
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    } finally {
      if (currentSeq == _searchSeq && isSearch) {
        isSearching.value = false;
      }
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
    _unfilteredRoutes.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _searchQuery = '';
    _searchDebounce?.cancel();
  }
}
