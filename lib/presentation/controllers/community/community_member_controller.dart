import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/community/community_member_model.dart';
import 'package:loci/data/models/community/community_member_response_model.dart';

class CommunityMemberController extends GetxController {
  // ── State ───────────────────────────────────────────────
  final List<CommunityMemberModel> _members = [];

  bool _isLoading = false;
  bool _isPaginationLoading = false;

  String? _errorMessage;
  PaginationMeta? _meta;

  int _currentPage = 1;
  String? _communityId;
  String _searchTerm = '';
  Timer? _debounce;
  int _totalCount = 0;

  // ── Getters ─────────────────────────────────────────────
  List<CommunityMemberModel> get members => _members;
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  PaginationMeta? get meta => _meta;

  bool get hasMore => _meta?.hasNextPage ?? false;
  int get totalCount => _totalCount;

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
      _isLoading = true;
      _errorMessage = null;

      if (isRefresh) {
        _currentPage = 1;
        _members.clear();
      }

      update();

      final queryParams = <String, dynamic>{
        'page': _currentPage,
        'limit': 20,
        if (_searchTerm.isNotEmpty) 'searchTerm': _searchTerm,
      };

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.communityMember(_communityId!),
        queryParams: queryParams,
      );

      if (response.isSuccess && response.body != null) {
        final result = CommunityMemberResponseModel.fromJson(response.body!);
        _members.addAll(result.data);
        _meta = result.meta;
        if (_searchTerm.isEmpty) _totalCount = result.meta.total;
      } else {
        _errorMessage =
            response.body?['message'] ?? 'Failed to load members';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ── Pagination ──────────────────────────────────────────
  Future<void> fetchMoreMembers() async {
    if (_communityId == null) return;
    if (!hasMore || _isLoading || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      update();

      final nextPage = _currentPage + 1;

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.communityMember(_communityId!),
        queryParams: {
          'page': nextPage,
          'limit': 20,
          if (_searchTerm.isNotEmpty) 'searchTerm': _searchTerm,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result =
        CommunityMemberResponseModel.fromJson(response.body!);

        _members.addAll(result.data);
        _meta = result.meta;
        _currentPage = nextPage;
      } else {
        _errorMessage =
            response.body?['message'] ?? 'Failed to load more members';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  // ── Refresh ─────────────────────────────────────────────
  Future<void> refreshMembers() async {
    await fetchMembers(isRefresh: true);
  }
}