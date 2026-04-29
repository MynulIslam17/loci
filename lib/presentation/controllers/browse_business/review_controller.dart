import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../data/models/common/paginatation_model.dart';
import '../../../data/models/review/review_model.dart';
import '../../../data/models/review/review_response_model.dart';

class ReviewController extends GetxController {
  final List<ReviewModel> _reviews = [];
  PaginationMeta? _meta;

  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _limit = 10;

  List<ReviewModel> get reviews => _reviews;
  PaginationMeta? get meta => _meta;

  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;

  bool get hasNextPage => _meta?.hasNextPage ?? false;

  /// ================= FETCH =================
  Future<void> fetchReviews({
    required String businessId,
    bool isRefresh = false,
  }) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        _reviews.clear();
      }

      _isLoading = true;
      _errorMessage = null;
      update();

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.businessReviews(
          businessId,
        ),
      );

      if (response.isSuccess && response.body != null) {
        final reviewResponse =
        ReviewResponseModel.fromJson(response.body!);

        _meta = reviewResponse.meta;
        _reviews.addAll(reviewResponse.reviews);
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load reviews";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// ================= LOAD MORE =================
  Future<void> loadMoreReviews(String businessId) async {
    if (!hasNextPage || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      update();

      _currentPage++;

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.businessReviews(
          businessId,
        ),
      );

      if (response.isSuccess && response.body != null) {
        final reviewResponse =
        ReviewResponseModel.fromJson(response.body!);

        _meta = reviewResponse.meta;
        _reviews.addAll(reviewResponse.reviews);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  /// ================= CLEAR =================
  void clear() {
    _reviews.clear();
    _meta = null;
    _currentPage = 1;
    _errorMessage = null;
    update();
  }
}