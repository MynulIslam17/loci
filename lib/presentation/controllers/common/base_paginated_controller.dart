import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/common/paginated_response.dart';

import '../../../data/models/common/paginatation_model.dart';

abstract class BasePaginationController<T> extends GetxController {
  final NetworkCaller network = Get.find<NetworkCaller>();

  String? errorMessage;
  bool isLoading = false;
  bool isLoadingMore = false;
  List<T> items = [];
  PaginationMeta? meta;

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

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  void _setLoadingMore(bool value) {
    isLoadingMore = value;
    update();
  }

  Future<void> fetchPage({int page = 1}) async {
    errorMessage = null;
    _setLoading(true);

    try {
      final result = await _requestPage(page);

      if (result == null) {
        items = [];
        return;
      }

      items = result.data;
      meta = result.meta;
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage || isLoading) return;

    _setLoadingMore(true);

    try {
      final result = await _requestPage(currentPage + 1);

      if (result != null) {
        items = [...items, ...result.data];
        meta = result.meta;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
    } finally {
      _setLoadingMore(false);
    }
  }

  Future<PaginatedResponse<T>?> _requestPage(int page) async {
    final params = {
      'page': page,
      'limit': 10,
      ...?queryParams,
    };

    final response = await network.getRequest(
      url: url,
      queryParams: params,
    );

    if (!response.isSuccess || response.body == null) {
      errorMessage = response.errorMessage ?? 'Something went wrong';
      return null;
    }

    return PaginatedResponse<T>.fromJson(response.body!, fromJson);
  }

  void nextPage() {
    if (hasNextPage) fetchPage(page: currentPage + 1);
  }

  void prevPage() {
    if (hasPrevPage) fetchPage(page: currentPage - 1);
  }
}
