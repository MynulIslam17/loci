import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';

class RaffleListController extends GetxController {
  RaffleListController(this._service);

  final RafflesService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<RaffleModel> _raffleList = <RaffleModel>[].obs;

  int _currentPage = 1;
  final int _limit = 10;
  bool _hasNextPage = true;

  String _searchQuery = '';
  Timer? _searchDebounce;
  final RxBool isSearching = false.obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  bool get isPaginationLoading => _fetch.loadingMore.value;
  String? get errorMessage => _errorMessage.value;
  List<RaffleModel> get raffleList => _raffleList;
  bool get hasNextPage => _hasNextPage;
  String get searchQuery => _searchQuery;

  void onSearchChanged(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchRaffles(isSearch: true);
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _searchDebounce?.cancel();
    fetchRaffles(isSearch: true);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchRaffles({
    bool isRefresh = false,
    bool isSearch = false,
  }) async {
    if (isRefresh || isSearch) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    if (isSearch) {
      isSearching.value = true;
    } else {
      _fetch.beginFirstPage(isRefresh: isRefresh);
    }
    _errorMessage.value = null;

    try {
      final model = await _service.getRaffles(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );

      _raffleList.assignAll(model.raffles);
      _hasNextPage = model.meta.hasNextPage;
      _currentPage++;
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      SnackbarService.error(_errorMessage.value!);
      _fetch.endFirstPage(markFetched: hasFetched);
    } finally {
      if (isSearch) isSearching.value = false;
    }
  }

  Future<void> loadMoreRaffles() async {
    if (isPaginationLoading ||
        !_hasNextPage ||
        isInitialLoading ||
        isRefreshing) {
      return;
    }

    _fetch.beginLoadMore();

    try {
      final model = await _service.getRaffles(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );

      _raffleList.addAll(model.raffles);
      _hasNextPage = model.meta.hasNextPage;
      _currentPage++;
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _fetch.endLoadMore();
    }
  }

  Future<void> refreshRaffles() => fetchRaffles(isRefresh: true);

  /// Updates an entered raffle in the active list
  void markRaffleEntered(String raffleId) {
    final idx = _raffleList.indexWhere((r) => r.id == raffleId);
    if (idx >= 0) {
      final old = _raffleList[idx];
      _raffleList[idx] = old.copyWith(
        isParticipating: true,
        participantCount: old.participantCount + 1,
      );
      _raffleList.refresh();
    }
  }
}
