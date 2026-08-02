import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/network/data/models/referral_response_model.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

class ReceivedReferralsController extends GetxController {
  ReceivedReferralsController(this._service);

  final NetworkService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<ReferralModel> _referrals = <ReferralModel>[].obs;
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => _fetch.loadingMore.value;
  String? get errorMessage => _errorMessage.value;
  List<ReferralModel> get referrals => List.unmodifiable(_referrals);
  PaginationMeta? get meta => _meta.value;

  int _currentPage = 1;
  static const int _limit = 10;
  String _searchTerm = '';
  Timer? _debounce;

  bool get hasNextPage => meta?.hasNextPage ?? false;
  String get searchTerm => _searchTerm;

  @override
  void onInit() {
    super.onInit();
    fetchReceivedReferrals();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchTerm = query.trim();
      fetchReceivedReferrals(isRefresh: true);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchTerm = '';
    fetchReceivedReferrals(isRefresh: true);
  }

  Future<void> fetchReceivedReferrals({bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;
    _currentPage = 1;

    try {
      await _loadPage(_currentPage, replace: true);
      _fetch.endFirstPage();
    } catch (_) {
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage || isInitialLoading || isRefreshing) {
      return;
    }

    _fetch.beginLoadMore();
    _currentPage++;

    try {
      await _loadPage(_currentPage, replace: false);
    } finally {
      _fetch.endLoadMore();
    }
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    try {
      final result = await _service.getReceivedReferrals(
        page: page,
        limit: _limit,
        searchTerm: _searchTerm,
      );
      if (replace) {
        _referrals.assignAll(result.data);
      } else {
        _referrals.addAll(result.data);
      }
      _meta.value = result.meta;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (page > 1) _currentPage--;
      rethrow;
    }
  }

  void replaceReferral(ReferralModel updated) {
    final index = _referrals.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _referrals[index] = updated;
    }
  }
}
