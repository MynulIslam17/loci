import 'package:get/get.dart';
import 'package:loci/features/raffles/data/models/raffles_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessRafflesListController extends GetxController {
  BusinessRafflesListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<RaffleModel> raffleList = <RaffleModel>[].obs;
  int _currentPage = 1;
  final RxBool hasMore = true.obs;
  final int _limit = 3;

  Future<void> fetchRaffles({
    bool isRefresh = false,
    required String businessId,
  }) async {
    if (isLoading.value) return;

    if (isRefresh) {
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

      if (isRefresh) {
        raffleList.assignAll(model.raffles);
      } else {
        raffleList.addAll(model.raffles);
      }

      hasMore.value = model.meta.hasNextPage;
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

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    raffleList.clear();
    _currentPage = 1;
    hasMore.value = true;
  }
}
