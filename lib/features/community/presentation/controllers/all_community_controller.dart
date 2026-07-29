import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/data/models/community_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/routes/app_routes.dart';

/// UI → [AllCommunityController] → [CommunityService] → repository → API.
class AllCommunityController extends GetxController {
  AllCommunityController(this._service);

  final CommunityService _service;

  final ScrollController scrollController = ScrollController();
  final isLoading = false.obs;
  final isPaginationLoading = false.obs;
  final errorMessage = RxnString();
  final searchQuery = ''.obs;

  final joined = <CommunityModel>[].obs;
  final available = <CommunityModel>[].obs;

  int _currentPage = 1;
  final int _limit = 4;
  final hasNextPage = true.obs;

  bool get hasMore => hasNextPage.value;
  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  /// Initial load failed and there is nothing to show.
  bool get hasFatalLoadError =>
      errorMessage.value != null &&
      joined.isEmpty &&
      available.isEmpty &&
      !isLoading.value;

  bool get showPaginationLoader => isPaginationLoading.value;

  bool get showEndOfAvailableList =>
      !hasNextPage.value && available.isNotEmpty;

  List<CommunityModel> get displayedJoined => _filter(joined);
  List<CommunityModel> get displayedAvailable => _filter(available);

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchCommunities();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  void clearSearch() => searchQuery.value = '';

  void openCommunity(CommunityModel community) {
    Get.toNamed(
      AppRoutes.communityScreen,
      arguments: {
        'communityRole': community.role,
        'communityId': community.id,
        'communityName': community.name,
      },
    );
  }

  void _scrollListener() {
    if (isLoading.value || isPaginationLoading.value) return;
    if (!hasNextPage.value) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreCommunities();
    }
  }

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

      joined.assignAll(model.joined);
      available.assignAll(model.available);
      hasNextPage.value = model.meta?.hasNextPage ?? false;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

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
      _currentPage--;
      errorMessage.value = 'Pagination error: $e';
    } finally {
      isPaginationLoading.value = false;
    }
  }

  Future<void> refreshCommunities() => fetchCommunities(isRefresh: true);

  void reset() {
    isLoading.value = false;
    isPaginationLoading.value = false;
    errorMessage.value = null;
    searchQuery.value = '';
    joined.clear();
    available.clear();
    _currentPage = 1;
    hasNextPage.value = true;
  }

  List<CommunityModel> _filter(List<CommunityModel> source) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return source;

    return source.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.category.label.toLowerCase().contains(q);
    }).toList();
  }
}
