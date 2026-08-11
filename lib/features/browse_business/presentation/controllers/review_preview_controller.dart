import 'package:get/get.dart';
import 'package:loci/shared/models/review_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class ReviewPreviewController extends GetxController {
  ReviewPreviewController(this._service);

  final BrowseBusinessService _service;

  final reviews = <ReviewModel>[].obs;
  final isLoading = false.obs;

  Future<void> fetchReviews(
    String businessId, {
    bool showLoading = true,
  }) async {
    final shouldShowLoading = showLoading && reviews.isEmpty;
    if (shouldShowLoading) isLoading.value = true;

    try {
      final model = await _service.getBusinessReviews(
        businessId: businessId,
        page: 1,
        limit: 10,
      );
      reviews.assignAll(model.reviews);
    } catch (_) {
      // Preserve previous silent failure behavior on load.
    } finally {
      if (shouldShowLoading) isLoading.value = false;
    }
  }

  void prependReview(ReviewModel review) {
    reviews.removeWhere((existing) => existing.id == review.id);
    reviews.insert(0, review);
  }

  List<ReviewModel> getLimited(int limit) {
    return reviews.length > limit
        ? reviews.sublist(0, limit)
        : reviews.toList();
  }
}
