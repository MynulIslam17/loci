import 'package:get/get.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_tab_list_cache.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';

class BusinessRafflesListController extends GetxController with ExploreTabListCache {
  BusinessRafflesListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<RaffleModel> raffleList = <RaffleModel>[].obs;
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
    await fetchRaffles(businessId: businessId, forceRefresh: _searchQuery.isNotEmpty);
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
    await fetchRaffles(businessId: businessId, forceRefresh: true);
  }

  Future<void> fetchRaffles({
    required String businessId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && isCachedFor(businessId, search: _searchQuery)) return;
    if (isLoading.value && !forceRefresh) return;

    if (businessChanged(businessId)) {
      _currentPage = 1;
      hasMore.value = true;
      raffleList.clear();
      _searchQuery = '';
      clearTabCache();
    }

    if (forceRefresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final model = await _service.getRaffles(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (forceRefresh || _currentPage == 1) {
        raffleList.assignAll(model.raffles);
      } else {
        raffleList.addAll(model.raffles);
      }

      hasMore.value = model.meta.hasNextPage;
      markCached(businessId, search: _searchQuery);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreRaffles({required String businessId}) async {
    if (!hasMore.value || isPaginationLoading.value || isLoading.value) return;

    isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.getRaffles(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      raffleList.addAll(model.raffles);
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
    final _ = raffleList.length;
    return showExploreEmptyState(
      businessId,
      isEmpty: raffleList.isEmpty,
      isLoading: isLoading.value,
      errorMessage: errorMessage.value,
      search: _searchQuery,
    );
  }

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    raffleList.clear();
    _currentPage = 1;
    _searchQuery = '';
    hasMore.value = true;
    clearTabCache();
  }

  void _syncSearchContext({required String businessId, required String search}) {
    if (businessChanged(businessId)) {
      _currentPage = 1;
      hasMore.value = true;
      raffleList.clear();
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
