import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';


import '../../../data/models/review/review_model.dart';
import '../../../data/models/review/review_response_model.dart';

class AllReviewsController extends GetxController {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _isPaginationLoading = false;

  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  bool get hasMore => _hasMore;

  late String _businessId;

  void init(String businessId) {
    _businessId = businessId;
    fetchReviews(refresh: true);
  }

  Future<void> fetchReviews({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _reviews.clear();
      _hasMore = true;
    }

    _isLoading = true;
    update();

    final url =
        "${AppUrl.businessReviews(_businessId)}?page=$_currentPage&limit=$_limit";

    final response =
    await Get.find<NetworkCaller>().getRequest(url: url);

    if (response.isSuccess && response.body != null) {
      final model = ReviewResponseModel.fromJson(response.body!);
      _reviews = model.reviews;
      _hasMore = model.meta.hasNextPage;
    }

    _isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isPaginationLoading) return;

    _isPaginationLoading = true;
    update();

    _currentPage++;

    final url =
        "${AppUrl.businessReviews(_businessId)}?page=$_currentPage&limit=$_limit";

    final response =
    await Get.find<NetworkCaller>().getRequest(url: url);

    if (response.isSuccess && response.body != null) {
      final model = ReviewResponseModel.fromJson(response.body!);
      _reviews.addAll(model.reviews);
      _hasMore = model.meta.hasNextPage;
    } else {
      _currentPage--;
    }

    _isPaginationLoading = false;
    update();
  }
}