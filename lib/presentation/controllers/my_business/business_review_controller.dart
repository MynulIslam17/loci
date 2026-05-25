import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/busniess/business_review_model.dart';
import 'package:loci/data/models/common/paginatation_model.dart';

class MyBusinessReviewController extends GetxController {
  final List<ReviewModel> _reviews = [];

  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  PaginationMeta? _meta;
  int _currentPage = 1;
  String? _businessId;

  final ScrollController scrollController = ScrollController();

  // ── Getters ──────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _meta?.hasNextPage ?? false;
  List<ReviewModel> get reviews => List.unmodifiable(_reviews);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchMore();
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> fetchReviews(String businessId, {bool isRefresh = false}) async {
    if (_isLoading) return;

    _businessId = businessId;

    try {
      _isLoading = true;
      _errorMessage = null;

      if (isRefresh) {
        _currentPage = 1;
        _reviews.clear();
      }

      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.myBusinessReviews(businessId),
        queryParams: {'page': _currentPage, 'limit': 10},
      );

      if (response.isSuccess && response.body != null) {
        final result = ReviewResponse.fromJson(response.body!);
        _reviews.addAll(result.data);
        _meta = result.meta;
      } else {
        _errorMessage = response.body?['message'] ?? 'Failed to load reviews';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> fetchMore() async {
    if (!hasMore || _isPaginationLoading || _isLoading || _businessId == null) return;

    try {
      _isPaginationLoading = true;
      _currentPage++;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.myBusinessReviews(_businessId!),
        queryParams: {'page': _currentPage, 'limit': 10},
      );

      if (response.isSuccess && response.body != null) {
        final result = ReviewResponse.fromJson(response.body!);
        _reviews.addAll(result.data);
        _meta = result.meta;
      } else {
        _currentPage--;
        _errorMessage = response.body?['message'] ?? 'Failed to load more reviews';
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }
}
