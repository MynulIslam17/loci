import 'package:get/get.dart';
import 'package:loci/features/event/data/models/event_list_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_tab_list_cache.dart';

class BusinessEventListController extends GetxController with ExploreTabListCache {
  BusinessEventListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<EventModel> eventList = <EventModel>[].obs;
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
    await fetchEvents(businessId: businessId, forceRefresh: _searchQuery.isNotEmpty);
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
    await fetchEvents(businessId: businessId, forceRefresh: true);
  }

  Future<void> fetchEvents({
    required String businessId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && isCachedFor(businessId, search: _searchQuery)) return;
    if (isLoading.value && !forceRefresh) return;
    if (isRefreshing.value && !forceRefresh) return;

    if (businessChanged(businessId)) {
      _currentPage = 1;
      hasMore.value = true;
      eventList.clear();
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
      final model = await _service.getEvents(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      eventList.assignAll(model.events);
      hasMore.value = model.meta.hasNextPage;
      markCached(businessId, search: _searchQuery);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      endExploreFetch(isLoading: isLoading);
    }
  }

  Future<void> loadMoreEvents({required String businessId}) async {
    if (!hasMore.value ||
        isPaginationLoading.value ||
        isLoading.value ||
        isRefreshing.value) {
      return;
    }

    isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.getEvents(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      eventList.addAll(model.events);
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
        hasItems: eventList.isNotEmpty,
      );

  bool showEmptyState(String businessId) {
    final _ = eventList.length;
    return showExploreEmptyState(
      businessId,
      isEmpty: eventList.isEmpty,
      isLoading: isLoading.value,
      errorMessage: errorMessage.value,
      search: _searchQuery,
    );
  }

  void reset() {
    endExploreFetch(isLoading: isLoading);
    isPaginationLoading.value = false;
    errorMessage.value = null;
    eventList.clear();
    _currentPage = 1;
    _searchQuery = '';
    hasMore.value = true;
    clearTabCache();
  }

  void _syncSearchContext({required String businessId, required String search}) {
    if (businessChanged(businessId)) {
      _currentPage = 1;
      hasMore.value = true;
      eventList.clear();
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
