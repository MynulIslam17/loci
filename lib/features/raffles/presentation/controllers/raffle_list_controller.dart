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
  final List<RaffleModel> _unfilteredRaffles = <RaffleModel>[];
  bool _unfilteredHasNextPage = true;

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasNextPage = true;

  String _searchQuery = '';
  Timer? _searchDebounce;
  int _searchSeq = 0;
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
    final hadSearch = _searchQuery.trim().isNotEmpty;
    _searchQuery = query;
    final seq = ++_searchSeq;
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      if (hadSearch) {
        _restoreUnfilteredList(sequenceToken: seq);
      }
    } else {
      isSearching.value = true;
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        fetchRaffles(isSearch: true, sequenceToken: seq);
      });
    }
  }

  void submitSearch(String query) {
    _searchDebounce?.cancel();
    if (query.trim() == _searchQuery && query.trim().isNotEmpty) return;
    _searchQuery = query;
    final seq = ++_searchSeq;
    if (query.trim().isEmpty) {
      _restoreUnfilteredList(sequenceToken: seq);
    } else {
      isSearching.value = true;
      fetchRaffles(isSearch: true, sequenceToken: seq);
    }
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return; // Do not refetch if already empty
    _searchQuery = '';
    _searchDebounce?.cancel();
    final seq = ++_searchSeq;
    _restoreUnfilteredList(sequenceToken: seq);
  }

  void _restoreUnfilteredList({int? sequenceToken}) {
    if (_unfilteredRaffles.isNotEmpty) {
      _raffleList.assignAll(_unfilteredRaffles);
      _hasNextPage = _unfilteredHasNextPage;
      isSearching.value = false;
      _errorMessage.value = null;
    } else {
      fetchRaffles(isSearch: true, sequenceToken: sequenceToken);
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchRaffles({
    bool isRefresh = false,
    bool isSearch = false,
    int? sequenceToken,
  }) async {
    final currentSeq = sequenceToken ?? ++_searchSeq;

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

      // Discard stale out-of-order response
      if (currentSeq != _searchSeq) return;

      _raffleList.assignAll(model.raffles);
      _hasNextPage = model.meta.hasNextPage;
      _currentPage++;
      _fetch.endFirstPage();

      if (_searchQuery.isEmpty && !isSearch) {
        _unfilteredRaffles.assignAll(model.raffles);
        _unfilteredHasNextPage = model.meta.hasNextPage;
      }
    } catch (e) {
      if (currentSeq != _searchSeq) return;
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      SnackbarService.error(_errorMessage.value!);
      _fetch.endFirstPage(markFetched: hasFetched);
    } finally {
      if (currentSeq == _searchSeq && isSearch) {
        isSearching.value = false;
      }
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
      final updated = old.copyWith(
        isParticipating: true,
        participantCount: old.participantCount + 1,
      );
      _raffleList[idx] = updated;
      final unfIdx = _unfilteredRaffles.indexWhere((r) => r.id == raffleId);
      if (unfIdx >= 0) {
        _unfilteredRaffles[unfIdx] = updated;
      }
      _raffleList.refresh();
    }
  }
}
