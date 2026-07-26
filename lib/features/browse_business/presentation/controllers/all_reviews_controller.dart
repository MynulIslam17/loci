import 'package:get/get.dart';
import 'package:loci/shared/models/review_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class AllReviewsController extends GetxController {
  AllReviewsController(this._service);

  final BrowseBusinessService _service;

  final reviews = <ReviewModel>[].obs;
  final isLoading = false.obs;
  final isPaginationLoading = false.obs;

  int _currentPage = 1;
  final int _limit = 10;
  final hasMore = true.obs;

  late String _businessId;

  void init(String businessId) {
    _businessId = businessId;
    fetchReviews(refresh: true);
  }

  Future<void> fetchReviews({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      reviews.clear();
      hasMore.value = true;
    }

    isLoading.value = true;

    try {
      final model = await _service.getBusinessReviews(
        businessId: _businessId,
        page: _currentPage,
        limit: _limit,
      );
      reviews.assignAll(model.reviews);
      hasMore.value = model.meta.hasNextPage;
    } catch (_) {
      // Preserve previous silent failure behavior on load.
    }

    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isPaginationLoading.value) return;

    isPaginationLoading.value = true;

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
    }

    isPaginationLoading.value = false;
  }
}
