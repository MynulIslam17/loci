import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/shared/models/review_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class AllReviewsController extends GetxController {
  AllReviewsController(this._service);

  final BrowseBusinessService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final reviews = <ReviewModel>[].obs;

  int _currentPage = 1;
  final int _limit = 10;
  final hasMore = true.obs;

  late String _businessId;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;
  bool get isPaginationLoading => _fetch.loadingMore.value;

  void init(String businessId) {
    _businessId = businessId;
    fetchReviews(refresh: true);
  }

  Future<void> fetchReviews({bool refresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    _fetch.beginFirstPage(isRefresh: refresh);

    try {
      final model = await _service.getBusinessReviews(
        businessId: _businessId,
        page: _currentPage,
        limit: _limit,
      );
      reviews.assignAll(model.reviews);
      hasMore.value = model.meta.hasNextPage;
      _fetch.endFirstPage();
    } catch (_) {
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value ||
        isPaginationLoading ||
        isInitialLoading ||
        isRefreshing) {
      return;
    }

    _fetch.beginLoadMore();
    _currentPage++;

    try {
      final model = await _service.getBusinessReviews(
        businessId: _businessId,
        page: _currentPage,
        limit: _limit,
      );
      reviews.addAll(model.reviews);
      hasMore.value = model.meta.hasNextPage;
    } catch (_) {
      _currentPage--;
    } finally {
      _fetch.endLoadMore();
    }
  }

  void prependReview(ReviewModel review) {
    reviews.removeWhere((existing) => existing.id == review.id);
    reviews.insert(0, review);
  }
}
