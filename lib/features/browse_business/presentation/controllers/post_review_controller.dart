import 'package:get/get.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';
import 'package:loci/features/browse_business/presentation/controllers/review_preview_controller.dart';

class PostReviewController extends GetxController {
  PostReviewController(this._service);

  final BrowseBusinessService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final isSuccess = false.obs;

  /// Posts a review for [businessId] with [rating] and [content].
  /// On success, refreshes the review preview list automatically.
  Future<bool> postReview({
    required String businessId,
    required double rating,
    required String content,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    isSuccess.value = false;

    try {
      await _service.postReview(
        businessId: businessId,
        rating: rating.toInt(),
        content: content,
      );
      isSuccess.value = true;
      await Get.find<ReviewPreviewController>().fetchReviews(businessId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }

    isLoading.value = false;

    return isSuccess.value;
  }
}
