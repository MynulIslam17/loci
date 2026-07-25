import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

abstract class BasePaginationController<T> extends GetxController {
  BasePaginationController(this._service);

  final CommonService _service;

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxList<T> _items = <T>[].obs;
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();

  String? get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
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
        !isLoading &&
        !isLoadingMore &&
        hasNextPage) {
      loadMore();
    }
  }

  Future<void> fetchPage({int page = 1}) async {
    _errorMessage.value = null;
    _isLoading.value = true;

    try {
      final result = await _service.getPaginated<T>(
        url: url,
        queryParams: {'page': page, 'limit': 10, ...?queryParams},
        fromJson: fromJson,
      );
      _items.assignAll(result.data);
      _meta.value = result.meta;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _items.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage || isLoading) return;

    _isLoadingMore.value = true;

    try {
      final result = await _service.getPaginated<T>(
        url: url,
        queryParams: {'page': currentPage + 1, 'limit': 10, ...?queryParams},
        fromJson: fromJson,
      );
      _items.addAll(result.data);
      _meta.value = result.meta;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void nextPage() {
    if (hasNextPage) fetchPage(page: currentPage + 1);
  }

  void prevPage() {
    if (hasPrevPage) fetchPage(page: currentPage - 1);
  }
}
