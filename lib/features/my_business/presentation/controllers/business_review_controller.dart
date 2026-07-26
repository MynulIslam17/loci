import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/business_review_model.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class MyBusinessReviewController extends GetxController {
  MyBusinessReviewController(this._service);

  final MyBusinessService _service;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();
  int _currentPage = 1;
  String? _businessId;

  final ScrollController scrollController = ScrollController();

  bool get hasMore => _meta.value?.hasNextPage ?? false;

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

  Future<void> fetchReviews(String businessId, {bool isRefresh = false}) async {
    if (isLoading.value) return;

    _businessId = businessId;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (isRefresh) {
        _currentPage = 1;
        reviews.clear();
      }

      final result = await _service.getBusinessReviews(
        businessId: businessId,
        page: _currentPage,
        limit: 10,
      );
      reviews.addAll(result.data);
      _meta.value = result.meta;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    if (!hasMore ||
        isPaginationLoading.value ||
        isLoading.value ||
        _businessId == null) {
      return;
    }

    try {
      isPaginationLoading.value = true;
      _currentPage++;

      final result = await _service.getBusinessReviews(
        businessId: _businessId!,
        page: _currentPage,
        limit: 10,
      );
      reviews.addAll(result.data);
      _meta.value = result.meta;
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPaginationLoading.value = false;
    }
  }
}
