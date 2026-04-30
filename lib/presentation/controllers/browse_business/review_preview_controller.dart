import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

import '../../../data/models/review/review_model.dart';
import '../../../data/models/review/review_response_model.dart';

class ReviewPreviewController extends GetxController {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(String businessId) async {
    _isLoading = true;
    update();

    final url =
        "${AppUrl.businessReviews(businessId)}?page=1&limit=10";

    final response =
    await Get.find<NetworkCaller>().getRequest(url: url);

    if (response.isSuccess && response.body != null) {
      final model = ReviewResponseModel.fromJson(response.body!);
      _reviews = model.reviews;
    }

    _isLoading = false;
    update();
  }

  List<ReviewModel> getLimited(int limit) {
    return _reviews.length > limit
        ? _reviews.sublist(0, limit)
        : _reviews;
  }
}