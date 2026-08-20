import 'dart:async';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class BrowseBusinessController extends GetxController {
  BrowseBusinessController(this._service, [HiveStorageService? storage])
      : _storage = storage ??
            (Get.isRegistered<HiveStorageService>()
                ? Get.find<HiveStorageService>()
                : null);

  final BrowseBusinessService _service;
  final HiveStorageService? _storage;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();
  StreamSubscription<void>? _reconnectSub;

  final errorMessage = RxnString();
  final businesses = <BrowseBusinessModel>[].obs;
  final List<BrowseBusinessModel> _unfilteredBusinesses = <BrowseBusinessModel>[];
  bool _unfilteredHasNextPage = true;
  final selectedCategory = Rxn<BusinessCategory>();

  int _currentPage = 1;
  final int _limit = 20;
  final hasNextPage = true.obs;

  String _searchQuery = '';
  Timer? _searchDebounce;
  int _searchSeq = 0;
  final RxBool isSearching = false.obs;

  String get searchQuery => _searchQuery;

  bool get hasMore => hasNextPage.value;
  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer =>
      _fetch.showInitialShimmer || (isSearching.value && businesses.isEmpty);
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;
  RxBool get isPaginationLoading => _fetch.loadingMore;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    final category = arg is BusinessCategory ? arg : null;

    // Frame-0 instant load from Hive cache ONLY when not opening for a specific category
    if (_storage != null && _searchQuery.isEmpty && category == null) {
      final cached = _storage.getFeedList('browse_business_feed');
      if (cached.isNotEmpty) {
        final parsed = cached
            .map((e) =>
                BrowseBusinessModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        businesses.assignAll(parsed);
        _unfilteredBusinesses.assignAll(parsed);
        _fetch.endFirstPage(markFetched: true);
      }
    }

    if (Get.isRegistered<ConnectivityService>()) {
      _reconnectSub = Get.find<ConnectivityService>().onReconnect.listen((_) {
        fetchBusinesses(selectedCategory.value, isRefresh: true);
      });
    }

    if (category != null) {
      initForCategory(category);
    } else if (businesses.isEmpty) {
      fetchBusinesses(null, isRefresh: true);
    }
  }

  /// Initializes or resets the feed for a new category selection, ensuring
  /// any previously loaded data from another category is immediately cleared
  /// and the shimmer is shown until new data is fetched.
  void initForCategory(BusinessCategory? category) {
    _searchQuery = '';
    _searchDebounce?.cancel();
    isSearching.value = false;
    _unfilteredBusinesses.clear();
    businesses.clear();
    _fetch.reset();
    _fetch.initialLoading.value = true;
    _fetch.hasFetched.value = false;
    _fetch.refreshing.value = false;
    selectedCategory.value = category;
    fetchBusinesses(category, isCategoryChange: true);
  }

  @override
  void onClose() {
    _reconnectSub?.cancel();
    _searchDebounce?.cancel();
    super.onClose();
  }

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
      businesses.clear();
      _fetch.initialLoading.value = true;
      _fetch.hasFetched.value = false;
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        fetchBusinesses(
          selectedCategory.value,
          isSearch: true,
          sequenceToken: seq,
        );
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
      businesses.clear();
      _fetch.initialLoading.value = true;
      _fetch.hasFetched.value = false;
      fetchBusinesses(
        selectedCategory.value,
        isSearch: true,
        sequenceToken: seq,
      );
    }
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _searchDebounce?.cancel();
    final seq = ++_searchSeq;
    _restoreUnfilteredList(sequenceToken: seq);
  }

  void _restoreUnfilteredList({int? sequenceToken}) {
    if (_unfilteredBusinesses.isNotEmpty) {
      businesses.assignAll(_unfilteredBusinesses);
      hasNextPage.value = _unfilteredHasNextPage;
      isSearching.value = false;
      _fetch.endFirstPage(markFetched: true);
      errorMessage.value = null;
    } else {
      fetchBusinesses(
        selectedCategory.value,
        isSearch: true,
        sequenceToken: sequenceToken,
      );
    }
  }

  Future<void> fetchBusinesses(
    BusinessCategory? category, {
    bool isRefresh = false,
    bool isSearch = false,
    bool isCategoryChange = false,
    int? sequenceToken,
  }) async {
    final currentSeq = sequenceToken ?? ++_searchSeq;

    try {
      if (isRefresh || isSearch || isCategoryChange) {
        _currentPage = 1;
        hasNextPage.value = true;
      }

      // Fast Offline Guard: short-circuit immediately if offline
      if (ConnectivityService.isCurrentOffline && !isSearch) {
        _fetch.endFirstPage(markFetched: true);
        return;
      }

      if (isCategoryChange) {
        _unfilteredBusinesses.clear();
        businesses.clear();
        isSearching.value = false;
        _fetch.initialLoading.value = true;
        _fetch.refreshing.value = false;
        _fetch.hasFetched.value = false;
      } else if (isSearch) {
        isSearching.value = true;
        businesses.clear();
        _fetch.initialLoading.value = true;
        _fetch.refreshing.value = false;
        _fetch.hasFetched.value = false;
      } else {
        _fetch.beginFirstPage(isRefresh: isRefresh);
      }
      errorMessage.value = null;
      selectedCategory.value = category;

      final model = await _service.browseBusinesses(
        page: _currentPage,
        limit: _limit,
        category: category?.toJson,
        search: _searchQuery,
      );

      if (currentSeq != _searchSeq) return;

      businesses.assignAll(model.data);
      hasNextPage.value = model.meta.hasNextPage;
      _fetch.endFirstPage();
      isSearching.value = false;

      if (_searchQuery.isEmpty && _currentPage == 1) {
        _unfilteredBusinesses.assignAll(model.data);
        _unfilteredHasNextPage = model.meta.hasNextPage;
      }

      if (_currentPage == 1 &&
          _searchQuery.isEmpty &&
          _storage != null &&
          model.data.isNotEmpty) {
        _storage.saveFeedList(
          'browse_business_feed',
          model.data.map((b) => b.toJson()).toList(),
        );
      }
    } catch (e) {
      if (currentSeq != _searchSeq) return;
      if (businesses.isEmpty) {
        errorMessage.value = AppErrorMessages.sanitize(e);
      }
      _fetch.endFirstPage(markFetched: hasFetched || businesses.isNotEmpty);
      isSearching.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasNextPage.value ||
        isPaginationLoading.value ||
        isInitialLoading ||
        isRefreshing) {
      return;
    }

    // Fast Offline Guard: do not paginate when offline
    if (ConnectivityService.isCurrentOffline) return;

    try {
      _fetch.beginLoadMore();
      _currentPage++;

      final model = await _service.browseBusinesses(
        page: _currentPage,
        limit: _limit,
        category: selectedCategory.value?.toJson,
        search: _searchQuery,
      );

      businesses.addAll(model.data);
      hasNextPage.value = model.meta.hasNextPage;
    } catch (e) {
      _currentPage--;
    } finally {
      _fetch.endLoadMore();
    }
  }

  void changeCategory(BusinessCategory? category) {
    fetchBusinesses(category, isCategoryChange: true);
  }

  Future<void> refreshData() async {
    await fetchBusinesses(selectedCategory.value, isRefresh: true);
  }
}
