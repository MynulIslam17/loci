import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/data/models/community_member_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/shared/models/pagination_model.dart';

class CommunityMemberController extends GetxController {
  CommunityMemberController(this._service);

  final CommunityService _service;

  final members = <CommunityMemberModel>[].obs;

  final isLoading = false.obs;
  final isPaginationLoading = false.obs;
  final isExporting = false.obs;

  final errorMessage = RxnString();
  final successMessage = RxnString();
  final meta = Rxn<PaginationMeta>();

  int _currentPage = 1;
  String? _communityId;

  /// Community whose members are already loaded in memory. Used to avoid
  /// re-hitting the API every time the screen is re-opened.
  String? _loadedCommunityId;
  String _searchTerm = '';
  Timer? _debounce;
  final totalCount = 0.obs;

  bool get hasMore => meta.value?.hasNextPage ?? false;

  /// Called when the screen opens. Fetches members only the first time for a
  /// given community; subsequent opens reuse the cached list. Use
  /// [refreshMembers] (pull-to-refresh) to force a reload.
  Future<void> init({
    required String communityId,
    bool forceRefresh = false,
  }) async {
    _communityId = communityId;
    if (!forceRefresh && _loadedCommunityId == communityId) return;
    await fetchMembers(isRefresh: true);
  }

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

  Future<void> fetchMembers({bool isRefresh = false}) async {
    final communityId = _communityId;
    if (communityId == null || communityId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (isRefresh) {
        _currentPage = 1;
        members.clear();
      }

      final result = await _service.getCommunityMembers(
        communityId: communityId,
        page: _currentPage,
        limit: 20,
        searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
      );
      members.addAll(result.data);
      meta.value = result.meta;
      _loadedCommunityId = communityId;
      if (_searchTerm.isEmpty) {
        totalCount.value = result.meta.total;
        _syncHeaderMemberCount();
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreMembers() async {
    final communityId = _communityId;
    if (communityId == null || communityId.isEmpty) return;
    if (!hasMore || isLoading.value || isPaginationLoading.value) return;

    try {
      isPaginationLoading.value = true;

      final nextPage = _currentPage + 1;

      final result = await _service.getCommunityMembers(
        communityId: communityId,
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

  Future<void> refreshMembers() async {
    await fetchMembers(isRefresh: true);
  }

  Future<bool> addMember({
    required String email,
    String? note,
  }) async {
    final communityId = _communityId;
    if (communityId == null || communityId.isEmpty) return false;

    try {
      errorMessage.value = null;
      successMessage.value = null;
      successMessage.value = await _service.addCommunityMember(
        communityId: communityId,
        email: email,
        note: note,
      );
      await fetchMembers(isRefresh: true);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> removeMember(String memberId) async {
    final communityId = _communityId;
    if (communityId == null || communityId.isEmpty) return false;

    try {
      errorMessage.value = null;
      await _service.removeMember(
        communityId: communityId,
        memberId: memberId,
      );
      members.removeWhere((m) => m.id == memberId);
      if (_searchTerm.isEmpty) {
        totalCount.value = (totalCount.value - 1).clamp(0, 1 << 30);
        _syncHeaderMemberCount();
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> exportMembers() async {
    final communityId = _communityId;
    if (communityId == null || communityId.isEmpty) return false;

    try {
      isExporting.value = true;
      errorMessage.value = null;
      final csv =
          await _service.exportCommunityMembers(communityId: communityId);
      final saved = await FilePicker.platform.saveFile(
        fileName: 'community_members.csv',
        bytes: utf8.encode(csv),
      );
      return saved != null;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isExporting.value = false;
    }
  }

  void _syncHeaderMemberCount() {
    final communityId = _communityId;
    if (communityId == null || communityId.isEmpty) return;
    if (!Get.isRegistered<MyCommunityController>()) return;
    Get.find<MyCommunityController>().updateMemberCount(totalCount.value);
  }
}
