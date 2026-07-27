import 'package:get/get.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_tab_list_cache.dart';
import 'package:loci/features/routes/data/models/routes_model.dart';

class BusinessRouteListController extends GetxController with ExploreTabListCache {
  BusinessRouteListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<RouteModel> routeList = <RouteModel>[].obs;
  final RxBool hasMore = true.obs;

  int _currentPage = 1;
  final int _limit = 2;

  Future<void> loadIfNeeded(String businessId) =>
      fetchRoutes(businessId: businessId);

  Future<void> fetchRoutes({
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
      final model = await _service.getRoutes(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
      );

      if (forceRefresh || _currentPage == 1) {
        routeList.assignAll(model.routes);
      } else {
        routeList.addAll(model.routes);
      }

      hasMore.value = model.meta.hasNextPage;
      markCached(businessId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreRoutes({required String? businessId}) async {
    if (!hasMore.value || isPaginationLoading.value || isLoading.value) return;
    if (businessId == null) return;

    isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.getRoutes(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
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

  bool showInitialLoader(String businessId) =>
      isLoading.value && !isCachedFor(businessId);

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    routeList.clear();
    _currentPage = 1;
    hasMore.value = true;
    clearTabCache();
  }
}
