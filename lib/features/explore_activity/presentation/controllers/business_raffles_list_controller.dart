import 'package:get/get.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_tab_list_cache.dart';
import 'package:loci/features/raffles/data/models/raffles_model.dart';

class BusinessRafflesListController extends GetxController with ExploreTabListCache {
  BusinessRafflesListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<RaffleModel> raffleList = <RaffleModel>[].obs;
  final RxBool hasMore = true.obs;

  int _currentPage = 1;
  final int _limit = 3;

  Future<void> loadIfNeeded(String businessId) =>
      fetchRaffles(businessId: businessId);

  Future<void> fetchRaffles({
    required String businessId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && isCachedFor(businessId)) return;
    if (isLoading.value) return;

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
      );

      if (forceRefresh || _currentPage == 1) {
        raffleList.assignAll(model.raffles);
      } else {
        raffleList.addAll(model.raffles);
      }

      hasMore.value = model.meta.hasNextPage;
      markCached(businessId);
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

  bool showInitialLoader(String businessId) =>
      isLoading.value && !isCachedFor(businessId);

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    raffleList.clear();
    _currentPage = 1;
    hasMore.value = true;
    clearTabCache();
  }
}
