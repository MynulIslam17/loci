import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/community/activity_model.dart';
import 'package:loci/data/models/community/activity_search_response.dart';

class SearchActivityController extends GetxController {
  // -------------------------------------------------
  // STATE
  // -------------------------------------------------
  final List<ActivityModel> _activities = [];
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  PaginationMeta? _meta;

  int _currentPage = 1;
  String _communityId = '';
  ActivityRefType _currentType = ActivityRefType.event;
  String _searchQuery = '';
  Timer? _debounce;

  static const int _limit = 5;

  // -------------------------------------------------
  // GETTERS
  // -------------------------------------------------
  List<ActivityModel> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  PaginationMeta? get meta => _meta;
  bool get hasMore => _meta?.hasNextPage ?? false;
  ActivityRefType get currentType => _currentType;

  // -------------------------------------------------
  // SETUP  (sets params, no fetch — call once on screen init)
  // -------------------------------------------------
  void setup(String communityId, ActivityRefType type) {
    _communityId = communityId;
    _currentType = type;
  }

  // -------------------------------------------------
  // DEBOUNCED ENTRY POINT — call this from the UI onChanged
  // -------------------------------------------------
  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _searchQuery = '';
      _activities.clear();
      _meta = null;
      update();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => search(query.trim()));
  }

  // -------------------------------------------------
  // SEARCH  (resets to page 1, triggers fetch)
  // -------------------------------------------------
  Future<void> search(String query) async {
    _searchQuery = query;
    await fetchActivities(isRefresh: true);
  }

  // -------------------------------------------------
  // CHANGE TYPE  (resets local state, no fetch until next search)
  // -------------------------------------------------
  void changeType(ActivityRefType type) {
    if (_currentType == type) return;
    _currentType = type;
    _searchQuery = '';
    _currentPage = 1;
    _activities.clear();
    _meta = null;
    update();
  }

  // -------------------------------------------------
  // FETCH FIRST PAGE
  // -------------------------------------------------
  Future<void> fetchActivities({bool isRefresh = false}) async {
    if (_communityId.isEmpty) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      if (isRefresh) {
        _currentPage = 1;
        _activities.clear();
      }

      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.searchActivity(_communityId),
        queryParams: {
          'communityId': _communityId,
          'type': _currentType.name,
          if (_searchQuery.isNotEmpty) 'search': _searchQuery,
          'page': _currentPage,
          'limit': _limit,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result = ActivitySearchResponse.fromJson(response.body!);
        _appendUnique(result.data);
        _meta = result.meta;
      } else {
        _errorMessage = response.body?['message'] ?? 'Failed to load activities';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  void _appendUnique(List<ActivityModel> items) {
    final seen = _activities.map((a) => a.id).toSet();
    for (final item in items) {
      if (item.id.isNotEmpty && seen.add(item.id)) {
        _activities.add(item);
      }
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // -------------------------------------------------
  // PAGINATION
  // -------------------------------------------------
  Future<void> fetchMore() async {
    if (!hasMore || _isPaginationLoading || _isLoading) return;

    try {
      _isPaginationLoading = true;
      update();

      _currentPage++;

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.searchActivity(_communityId),
        queryParams: {
          'communityId': _communityId,
          'type': _currentType.name,
          if (_searchQuery.isNotEmpty) 'search': _searchQuery,
          'page': _currentPage,
          'limit': _limit,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result = ActivitySearchResponse.fromJson(response.body!);
        _appendUnique(result.data);
        _meta = result.meta;
      } else {
        _currentPage--;
        _errorMessage = response.body?['message'] ?? 'Failed to load more';
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
