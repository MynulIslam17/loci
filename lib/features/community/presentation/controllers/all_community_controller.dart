import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/data/models/community_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class AllCommunityController extends GetxController {
  AllCommunityController(this._service);

  final CommunityService _service;

  final ScrollController scrollController = ScrollController();
  final isLoading = false.obs;
  final isPaginationLoading = false.obs;
  final errorMessage = RxnString();

  final joined = <CommunityModel>[].obs;
  final available = <CommunityModel>[].obs;

  int _currentPage = 1;
  final int _limit = 4;
  final hasNextPage = true.obs;

  bool get hasMore => hasNextPage.value;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchCommunities();
  }

  void _scrollListener() {
    if (isLoading.value || isPaginationLoading.value) return;
    if (!hasNextPage.value) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreCommunities();
    }
  }

  @override
  void onClose() {
    // Crucial: Dispose the ScrollController when the controller is destroyed
    scrollController.dispose();
    super.onClose();
  }

  // ===========================================================
  // FETCH COMMUNITIES (FIRST LOAD / REFRESH)
  // ===========================================================
  Future<void> fetchCommunities({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      hasNextPage.value = true;
      available.clear();
      joined.clear();
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final model = await _service.getCommunities(
        page: _currentPage,
        limit: _limit,
      );

      // joined always replace (no pagination needed)
      joined.assignAll(model.joined);

      // available list handling (EVENT STYLE)
      available.assignAll(model.available);

      hasNextPage.value = model.meta?.hasNextPage ?? false;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================
  // LOAD MORE (PAGINATION)
  // ===========================================================
  Future<void> loadMoreCommunities() async {
    if (!hasNextPage.value || isPaginationLoading.value) return;

    isPaginationLoading.value = true;
    _currentPage++;

    try {
      final model = await _service.getCommunities(
        page: _currentPage,
        limit: _limit,
      );

      available.addAll(model.available);

      hasNextPage.value = model.meta?.hasNextPage ?? false;
    } catch (e) {
      _currentPage--; // rollback
      errorMessage.value = 'Pagination error: $e';
    } finally {
      isPaginationLoading.value = false;
    }
  }

  // ===========================================================
  // REFRESH
  // ===========================================================
  Future<void> refreshCommunities() async {
    await fetchCommunities(isRefresh: true);
  }

  // ===========================================================
  // RESET
  // ===========================================================
  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;

    joined.clear();
    available.clear();

    _currentPage = 1;
    hasNextPage.value = true;
  }
}
