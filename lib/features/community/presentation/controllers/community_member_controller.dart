import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/community/data/models/community_member_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class CommunityMemberController extends GetxController {
  CommunityMemberController(this._service);

  final CommunityService _service;

  // ── State ───────────────────────────────────────────────
  final members = <CommunityMemberModel>[].obs;

  final isLoading = false.obs;
  final isPaginationLoading = false.obs;

  final errorMessage = RxnString();
  final meta = Rxn<PaginationMeta>();

  int _currentPage = 1;
  String? _communityId;
  String _searchTerm = '';
  Timer? _debounce;
  final totalCount = 0.obs;

  bool get hasMore => meta.value?.hasNextPage ?? false;

  // ── Init ────────────────────────────────────────────────
  Future<void> init(String communityId) async {
    _communityId = communityId;
    await fetchMembers(isRefresh: true);
  }

  // ── Search ───────────────────────────────────────────────
  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchTerm = query.trim();
      fetchMembers(isRefresh: true);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchTerm = '';
    fetchMembers(isRefresh: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ── Fetch Members ────────────────────────────────────────
  Future<void> fetchMembers({bool isRefresh = false}) async {
    if (_communityId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (isRefresh) {
        _currentPage = 1;
        members.clear();
      }

      final result = await _service.getCommunityMembers(
        communityId: _communityId!,
        page: _currentPage,
        limit: 20,
        searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
      );
      members.addAll(result.data);
      meta.value = result.meta;
      if (_searchTerm.isEmpty) totalCount.value = result.meta.total;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Pagination ──────────────────────────────────────────
  Future<void> fetchMoreMembers() async {
    if (_communityId == null) return;
    if (!hasMore || isLoading.value || isPaginationLoading.value) return;

    try {
      isPaginationLoading.value = true;

      final nextPage = _currentPage + 1;

      final result = await _service.getCommunityMembers(
        communityId: _communityId!,
        page: nextPage,
        limit: 20,
        searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
      );

      members.addAll(result.data);
      meta.value = result.meta;
      _currentPage = nextPage;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPaginationLoading.value = false;
    }
  }

  // ── Refresh ─────────────────────────────────────────────
  Future<void> refreshMembers() async {
    await fetchMembers(isRefresh: true);
  }
}
