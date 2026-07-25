import 'package:get/get.dart';
import 'package:loci/features/routes/data/models/routes_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessRouteListController extends GetxController {
  BusinessRouteListController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<RouteModel> routeList = <RouteModel>[].obs;
  int _currentPage = 1;
  final RxBool hasMore = true.obs;
  final int _limit = 2;

  Future<void> fetchRoutes({
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
      final model = await _service.getRoutes(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
      );

      if (isRefresh) {
        routeList.assignAll(model.routes);
      } else {
        routeList.addAll(model.routes);
      }

      hasMore.value = model.meta.hasNextPage;
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

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    routeList.clear();
    _currentPage = 1;
    hasMore.value = true;
  }
}
