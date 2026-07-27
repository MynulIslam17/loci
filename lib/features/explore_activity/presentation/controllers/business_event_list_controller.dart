import 'package:get/get.dart';
import 'package:loci/features/event/data/models/event_model.dart';
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
  final int _limit = 2;

  /// First visit: loads and shows spinner. Returns instantly when cached.
  Future<void> loadIfNeeded(String businessId) =>
      fetchEvents(businessId: businessId);

  Future<void> fetchEvents({
    required String businessId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && isCachedFor(businessId)) return;

    if (forceRefresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final model = await _service.getEvents(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
      );
      eventList.assignAll(model.events);
      hasMore.value = model.meta.hasNextPage;
      markCached(businessId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreEvents({required String businessId}) async {
    if (!hasMore.value || isPaginationLoading.value || isLoading.value) return;

    isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.getEvents(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
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

  bool showInitialLoader(String businessId) =>
      isLoading.value && !isCachedFor(businessId);

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    eventList.clear();
    _currentPage = 1;
    hasMore.value = true;
    clearTabCache();
  }
}
