import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/community/data/models/activity_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class SearchActivityController extends GetxController {
  SearchActivityController(this._service);

  final CommunityService _service;

  // -------------------------------------------------
  // STATE
  // -------------------------------------------------
  final activities = <ActivityModel>[].obs;
  final isLoading = false.obs;
  final isPaginationLoading = false.obs;
  final errorMessage = RxnString();
  final meta = Rxn<PaginationMeta>();

  int _currentPage = 1;
  String _communityId = '';
  final currentType = ActivityRefType.event.obs;
  String _searchQuery = '';
  Timer? _debounce;

  static const int _limit = 5;

  bool get hasMore => meta.value?.hasNextPage ?? false;

  // -------------------------------------------------
  // SETUP  (sets params, no fetch — call once on screen init)
  // -------------------------------------------------
  void setup(String communityId, ActivityRefType type) {
    _communityId = communityId;
    currentType.value = type;
  }

  // -------------------------------------------------
  // DEBOUNCED ENTRY POINT — call this from the UI onChanged
  // -------------------------------------------------
  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _searchQuery = '';
      activities.clear();
      meta.value = null;
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => search(query.trim()),
    );
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
    if (currentType.value == type) return;
    currentType.value = type;
    _searchQuery = '';
    _currentPage = 1;
    activities.clear();
    meta.value = null;
  }

  // -------------------------------------------------
  // FETCH FIRST PAGE
  // -------------------------------------------------
  Future<void> fetchActivities({bool isRefresh = false}) async {
    if (_communityId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (isRefresh) {
        _currentPage = 1;
        activities.clear();
      }

      final result = await _service.searchActivities(
        communityId: _communityId,
        type: currentType.value.name,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        limit: _limit,
      );
      _appendUnique(result.data);
      meta.value = result.meta;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _appendUnique(List<ActivityModel> items) {
    final seen = activities.map((a) => a.id).toSet();
    for (final item in items) {
      if (item.id.isNotEmpty && seen.add(item.id)) {
        activities.add(item);
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
    if (!hasMore || isPaginationLoading.value || isLoading.value) return;

    try {
      isPaginationLoading.value = true;

      _currentPage++;

      final result = await _service.searchActivities(
        communityId: _communityId,
        type: currentType.value.name,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        limit: _limit,
      );
      _appendUnique(result.data);
      meta.value = result.meta;
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPaginationLoading.value = false;
    }
  }
}
