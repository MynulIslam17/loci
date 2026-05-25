import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/presentation/controllers/browse_business/review_preview_controller.dart';

class PostReviewController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Posts a review for [businessId] with [rating] and [content].
  /// On success, refreshes the review preview list automatically.
  Future<bool> postReview({
    required String businessId,
    required double rating,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    update();

    final url = AppUrl.addReviews(businessId);

    final response = await Get.find<NetworkCaller>().postRequest(
      url: url,
      body: {
        'rating': rating.toInt(),
        'content': content,
      },
    );

    if (response.isSuccess) {
      _isSuccess = true;
      // Refresh the preview list so the new review shows up immediately
      await Get.find<ReviewPreviewController>().fetchReviews(businessId);
    } else {
      _errorMessage = response.errorMessage;
    }

    _isLoading = false;
    update();

    return _isSuccess;
  }
}
