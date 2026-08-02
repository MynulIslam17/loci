import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/my_business/data/models/business_review_model.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class MyBusinessReviewController extends GetxController {
  MyBusinessReviewController(this._service);

  final MyBusinessService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final RxnString errorMessage = RxnString();
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();
  int _currentPage = 1;
  String? _businessId;

  final ScrollController scrollController = ScrollController();

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;
  bool get isPaginationLoading => _fetch.loadingMore.value;

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
    if (isInitialLoading || isRefreshing) return;

    _businessId = businessId;
    _fetch.beginFirstPage(isRefresh: isRefresh);
    errorMessage.value = null;
    _currentPage = 1;

    try {
      await _loadPage(replace: true);
      _fetch.endFirstPage();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> fetchMore() async {
    if (!hasMore ||
        isPaginationLoading ||
        isInitialLoading ||
        isRefreshing ||
        _businessId == null) {
      return;
    }

    _fetch.beginLoadMore();
    _currentPage++;

    try {
      await _loadPage(replace: false);
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _fetch.endLoadMore();
    }
  }

  Future<void> _loadPage({required bool replace}) async {
    final result = await _service.getBusinessReviews(
      businessId: _businessId!,
      page: _currentPage,
      limit: 10,
    );
    if (replace) {
      reviews.assignAll(result.data);
    } else {
      reviews.addAll(result.data);
    }
    _meta.value = result.meta;
  }
}
