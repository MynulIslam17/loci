import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

abstract class BasePaginationController<T> extends GetxController {
  BasePaginationController(this._service);

  final CommonService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<T> _items = <T>[].obs;
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();

  String? get errorMessage => _errorMessage.value;
  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get isLoadingMore => _fetch.loadingMore.value;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  /// Backward-compatible alias — initial load only, not refresh.
  bool get isLoading => isInitialLoading;
  List<T> get items => _items;
  PaginationMeta? get meta => _meta.value;

  final ScrollController scrollController = ScrollController();

  String get url;
  Map<String, dynamic>? get queryParams => null;
  T Function(Map<String, dynamic>) get fromJson;
  bool get shouldFetchOnInit => true;

  bool get hasNextPage => meta?.hasNextPage ?? false;
  bool get hasPrevPage => meta?.hasPrevPage ?? false;
  int get currentPage => meta?.page ?? 1;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    if (shouldFetchOnInit) fetchPage();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 &&
        !isInitialLoading &&
        !isRefreshing &&
        !isLoadingMore &&
        hasNextPage) {
      loadMore();
    }
  }

  Future<void> fetchPage({int page = 1, bool isRefresh = false}) async {
    if (page == 1) {
      _fetch.beginFirstPage(isRefresh: isRefresh);
    } else {
      _fetch.beginLoadMore();
    }
    _errorMessage.value = null;

    try {
      final result = await _service.getPaginated<T>(
        url: url,
        queryParams: {'page': page, 'limit': 10, ...?queryParams},
        fromJson: fromJson,
      );
      if (page == 1) {
        _items.assignAll(result.data);
      } else {
        _items.addAll(result.data);
      }
      _meta.value = result.meta;
      if (page == 1) _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (page == 1 && !hasFetched) _items.clear();
      if (page == 1) {
        _fetch.endFirstPage(markFetched: hasFetched);
      } else {
        _fetch.endLoadMore();
      }
      return;
    }

    if (page > 1) _fetch.endLoadMore();
  }

  Future<void> reload() => fetchPage(page: 1, isRefresh: true);

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage || isInitialLoading || isRefreshing) {
      return;
    }
    await fetchPage(page: currentPage + 1);
  }

  void nextPage() {
    if (hasNextPage) fetchPage(page: currentPage + 1);
  }

  void prevPage() {
    if (hasPrevPage) fetchPage(page: currentPage - 1);
  }
}
