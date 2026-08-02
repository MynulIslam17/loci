import 'package:get/get.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_tab_list_cache.dart';
import 'package:loci/features/routes/data/models/route_list_model.dart';

class BusinessRouteListController extends GetxController with ExploreTabListCache {
  BusinessRouteListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<RouteModel> routeList = <RouteModel>[].obs;
  final RxBool hasMore = true.obs;

  int _currentPage = 1;
  final int _limit = 10;
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  Future<void> loadIfNeeded(String businessId, {String search = ''}) =>
      ensureLoaded(businessId: businessId, search: search);

  Future<void> ensureLoaded({
    required String businessId,
    required String search,
  }) async {
    _syncSearchContext(businessId: businessId, search: search.trim());
    if (isCachedFor(businessId, search: _searchQuery)) return;
    await fetchRoutes(businessId: businessId, forceRefresh: _searchQuery.isNotEmpty);
  }

  Future<void> applySearch({
    required String businessId,
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed == _searchQuery && isCachedFor(businessId, search: trimmed)) {
      return;
    }
    _searchQuery = trimmed;
    _currentPage = 1;
    hasMore.value = true;
    clearTabCache();
    await fetchRoutes(businessId: businessId, forceRefresh: true);
  }

  Future<void> fetchRoutes({
    required String businessId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && isCachedFor(businessId, search: _searchQuery)) return;
    if (isLoading.value && !forceRefresh) return;
    if (isRefreshing.value && !forceRefresh) return;

    if (businessChanged(businessId)) {
      _currentPage = 1;
      hasMore.value = true;
      routeList.clear();
      _searchQuery = '';
      clearTabCache();
    }

    if (forceRefresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    beginExploreFetch(
      isLoading: isLoading,
      forceRefresh: forceRefresh,
      businessId: businessId,
      errorMessage: errorMessage.value,
      search: _searchQuery,
    );
    errorMessage.value = null;

    try {
      final model = await _service.getRoutes(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (forceRefresh || _currentPage == 1) {
        routeList.assignAll(model.routes);
      } else {
        routeList.addAll(model.routes);
      }

      hasMore.value = model.meta.hasNextPage;
      markCached(businessId, search: _searchQuery);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      endExploreFetch(isLoading: isLoading);
    }
  }

  Future<void> loadMoreRoutes({required String? businessId}) async {
    if (!hasMore.value ||
        isPaginationLoading.value ||
        isLoading.value ||
        isRefreshing.value) {
      return;
    }
    if (businessId == null) return;

    isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.getRoutes(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      routeList.addAll(model.routes);
      hasMore.value = model.meta.hasNextPage;
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPaginationLoading.value = false;
    }
  }

  bool showInitialLoader(String businessId) => showExploreInitialLoader(
        businessId,
        errorMessage: errorMessage.value,
        search: _searchQuery,
      );

  bool showEmptyState(String businessId) {
    final _ = routeList.length;
    return showExploreEmptyState(
      businessId,
      isEmpty: routeList.isEmpty,
      isLoading: isLoading.value,
      errorMessage: errorMessage.value,
      search: _searchQuery,
    );
  }

  void reset() {
    endExploreFetch(isLoading: isLoading);
    isPaginationLoading.value = false;
    errorMessage.value = null;
    routeList.clear();
    _currentPage = 1;
    _searchQuery = '';
    hasMore.value = true;
    clearTabCache();
  }

  void _syncSearchContext({required String businessId, required String search}) {
    if (businessChanged(businessId)) {
      _currentPage = 1;
      hasMore.value = true;
      routeList.clear();
      _searchQuery = '';
      clearTabCache();
    }
    if (_searchQuery != search) {
      _searchQuery = search;
      _currentPage = 1;
      hasMore.value = true;
      clearTabCache();
    }
  }
}
