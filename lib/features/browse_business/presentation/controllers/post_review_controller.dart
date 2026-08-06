import 'package:get/get.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/shared/models/review_author_model.dart';
import 'package:loci/shared/models/review_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';
import 'package:loci/features/browse_business/presentation/controllers/all_reviews_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/review_preview_controller.dart';

class PostReviewController extends GetxController {
  PostReviewController(this._service);

  final BrowseBusinessService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();
  final isSuccess = false.obs;

  Future<bool> postReview({
    required String businessId,
    required double rating,
    required String content,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;
    isSuccess.value = false;

    try {
      final result = await _service.postReview(
        businessId: businessId,
        rating: rating.toInt(),
        content: content,
      );
      _applyReviewLocally(_withCurrentUser(result.review), businessId);
      successMessage.value = result.message;
      isSuccess.value = true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }

    return isSuccess.value;
  }

  /// The create-review response only returns the author's id, so fill in the
  /// signed-in user's name/avatar for the optimistic list entry.
  ReviewModel _withCurrentUser(ReviewModel review) {
    if (review.author.name.isNotEmpty) return review;
    final me = Get.find<AuthController>().userModel;
    if (me == null) return review;
    return ReviewModel(
      id: review.id,
      author: ReviewAuthor(
        id: review.author.id,
        name: me.name,
        avatar: me.avatar ?? '',
      ),
      businessId: review.businessId,
      rating: review.rating,
      content: review.content,
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
    );
  }

  void _applyReviewLocally(ReviewModel review, String businessId) {
    Get.find<ReviewPreviewController>().prependReview(review);

    if (Get.isRegistered<AllReviewsController>()) {
      Get.find<AllReviewsController>().prependReview(review);
    }
  }
}
