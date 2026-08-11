import 'package:get/get.dart';

/// Separates first-load shimmer from pull-to-refresh across paginated lists.
///
/// - First page, never loaded → [initialLoading] (show shimmer)
/// - First page, refresh → [refreshing] (keep list, native spinner)
/// - Page 2+ → [loadingMore]
class PaginatedListFetchState {
  final RxBool initialLoading = false.obs;
  final RxBool refreshing = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasFetched = false.obs;

  bool get showInitialShimmer => initialLoading.value && !hasFetched.value;

  bool get isBusy =>
      initialLoading.value || refreshing.value || loadingMore.value;

  void beginFirstPage({required bool isRefresh}) {
    if (!hasFetched.value) {
      initialLoading.value = true;
      refreshing.value = false;
      return;
    }
    if (isRefresh) {
      refreshing.value = true;
      initialLoading.value = false;
      return;
    }
    initialLoading.value = true;
    refreshing.value = false;
  }

  void beginLoadMore() {
    loadingMore.value = true;
  }

  void endFirstPage({bool markFetched = true}) {
    initialLoading.value = false;
    refreshing.value = false;
    if (markFetched) hasFetched.value = true;
  }

  void endLoadMore() {
    loadingMore.value = false;
  }

  void reset() {
    initialLoading.value = false;
    refreshing.value = false;
    loadingMore.value = false;
    hasFetched.value = false;
  }
}
