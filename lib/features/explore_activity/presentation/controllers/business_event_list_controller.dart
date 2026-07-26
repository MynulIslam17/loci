import 'package:get/get.dart';
import 'package:loci/features/event/data/models/event_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessEventListController extends GetxController {
  BusinessEventListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<EventModel> eventList = <EventModel>[].obs;
  int _currentPage = 1;
  final RxBool hasMore = true.obs;
  final int _limit = 2;

  Future<void> fetchEvents({
    bool isRefresh = false,
    required String businessId,
  }) async {
    if (isRefresh) {
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

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    eventList.clear();
    _currentPage = 1;
    hasMore.value = true;
  }
}
