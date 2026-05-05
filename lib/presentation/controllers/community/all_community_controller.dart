import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

import '../../../data/community/community_model.dart';
import '../../../data/community/community_response_model.dart';

class AllCommunityController extends GetxController {
  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;

  List<CommunityModel> _joined = [];
  List<CommunityModel> _available = [];

  int _currentPage = 1;
  final int _limit = 4;
  bool _hasNextPage = true;

  // ---------------- GETTERS ----------------
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;

  List<CommunityModel> get joined => _joined;
  List<CommunityModel> get available => _available;

  bool get hasMore => _hasNextPage;



  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchCommunities();
  }
  void _scrollListener() {
    if(_isLoading && _isPaginationLoading)return;
    if (!_hasNextPage) return;
    // Check if user is near the bottom (within 200 pixels)
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
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
      _hasNextPage = true;
      _available.clear();
      _joined.clear();

    }

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.community,
        queryParams: {
          "page": _currentPage,
          "limit": _limit,
        },
      );

      if (response.isSuccess && response.body != null) {
        final model = CommunityResponseModel.fromJson(response.body!);

        // joined always replace (no pagination needed)
        _joined = model.joined;

        // available list handling (EVENT STYLE)
        _available = model.available;

        _hasNextPage = model.meta?.hasNextPage ?? false;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to load communities";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ===========================================================
  // LOAD MORE (PAGINATION)
  // ===========================================================
  Future<void> loadMoreCommunities() async {
    if (!_hasNextPage || _isPaginationLoading) return;

    _isPaginationLoading = true;
    _currentPage++;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.community,
        queryParams: {
          "page": _currentPage,
          "limit": _limit,
        },
      );

      if (response.isSuccess && response.body != null) {
        final model = CommunityResponseModel.fromJson(response.body!);

        _available.addAll(model.available);

        _hasNextPage = model.meta?.hasNextPage ?? false;
      } else {
        _currentPage--; // rollback
      }
    } catch (e) {
      _currentPage--; // rollback
      _errorMessage = "Pagination error: $e";
    } finally {
      _isPaginationLoading = false;
      update();
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
    _isLoading = false;
    _isPaginationLoading = false;
    _errorMessage = null;

    _joined.clear();
    _available.clear();

    _currentPage = 1;
    _hasNextPage = true;

    update();
  }
}