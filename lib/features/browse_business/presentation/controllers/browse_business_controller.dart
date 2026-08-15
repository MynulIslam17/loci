import 'dart:async';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/services/connectivity_service.dart';
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
  final selectedCategory = Rxn<BusinessCategory>();

  int _currentPage = 1;
  final int _limit = 20;
  final hasNextPage = true.obs;

  String _searchQuery = '';
  Timer? _searchDebounce;

  String get searchQuery => _searchQuery;

  bool get hasMore => hasNextPage.value;
  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;
  RxBool get isPaginationLoading => _fetch.loadingMore;

  @override
  void onInit() {
    super.onInit();

    // Frame-0 instant load from Hive cache
    if (_storage != null && _searchQuery.isEmpty) {
      final cached = _storage.getFeedList('browse_business_feed');
      if (cached.isNotEmpty) {
        businesses.assignAll(
          cached
              .map((e) =>
                  BrowseBusinessModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
        _fetch.endFirstPage(markFetched: true);
      }
    }

    if (Get.isRegistered<ConnectivityService>()) {
      _reconnectSub = Get.find<ConnectivityService>().onReconnect.listen((_) {
        fetchBusinesses(selectedCategory.value, isRefresh: true);
      });
    }

    final arg = Get.arguments;

    if (arg != null && arg is BusinessCategory) {
      fetchBusinesses(arg, isRefresh: true);
    } else {
      fetchBusinesses(null, isRefresh: true);
    }
  }

  @override
  void onClose() {
    _reconnectSub?.cancel();
    _searchDebounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchBusinesses(selectedCategory.value, isSearch: true);
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _searchDebounce?.cancel();
    fetchBusinesses(selectedCategory.value, isSearch: true);
  }

  Future<void> fetchBusinesses(
    BusinessCategory? category, {
    bool isRefresh = false,
    bool isSearch = false,
  }) async {
    try {
      if (isRefresh || isSearch) {
        _currentPage = 1;
        hasNextPage.value = true;
      }

      // Fast Offline Guard: short-circuit immediately if offline
      if (ConnectivityService.isCurrentOffline && !isSearch) {
        _fetch.endFirstPage(markFetched: true);
        return;
      }

      if (isSearch) {
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

      businesses.assignAll(model.data);
      hasNextPage.value = model.meta.hasNextPage;
      _fetch.endFirstPage();

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
      if (businesses.isEmpty) {
        errorMessage.value = AppErrorMessages.sanitize(e);
      }
      _fetch.endFirstPage(markFetched: hasFetched || businesses.isNotEmpty);
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
    fetchBusinesses(category, isRefresh: true);
  }

  Future<void> refreshData() async {
    await fetchBusinesses(selectedCategory.value, isRefresh: true);
  }
}
