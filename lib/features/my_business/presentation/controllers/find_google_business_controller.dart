import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/find_business_response.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class FindGoogleBusinessController extends GetxController {
  FindGoogleBusinessController(this._service);

  final MyBusinessService _service;

  final RxnString search = RxnString();
  final Rxn<Business> selectedBusiness = Rxn<Business>();
  final RxBool showResults = false.obs;

  final RxnString errorMessage = RxnString();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Business> items = <Business>[].obs;
  final Rxn<PaginationMeta> meta = Rxn<PaginationMeta>();

  final ScrollController scrollController = ScrollController();

  bool get hasNextPage => meta.value?.hasNextPage ?? false;
  int get currentPage => meta.value?.page ?? 1;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
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
        !isLoading.value &&
        !isLoadingMore.value &&
        hasNextPage) {
      loadMore();
    }
  }

  void _setLoading(bool value) {
    isLoading.value = value;
  }

  void _setLoadingMore(bool value) {
    isLoadingMore.value = value;
  }

  Future<void> fetchPage({int page = 1}) async {
    errorMessage.value = null;
    _setLoading(true);

    try {
      final result = await _service.findGoogleBusinesses(
        page: page,
        limit: 10,
        search: search.value,
      );
      items.assignAll(result.data);
      meta.value = result.meta;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      items.clear();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasNextPage || isLoading.value) return;

    _setLoadingMore(true);

    try {
      final result = await _service.findGoogleBusinesses(
        page: currentPage + 1,
        limit: 10,
        search: search.value,
      );
      items.addAll(result.data);
      meta.value = result.meta;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoadingMore(false);
    }
  }

  void searchBusinesses(String query) {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      search.value = null;
      items.clear();
      meta.value = null;
      errorMessage.value = null;
      showResults.value = false;
      clearSelection();
      return;
    }

    if (selectedBusiness.value != null) {
      selectedBusiness.value = null;
    }

    search.value = trimmed;
    showResults.value = true;
    fetchPage();
  }

  void selectBusiness(Business business) {
    selectedBusiness.value = business;
    search.value = null;
    items.clear();
    meta.value = null;
    errorMessage.value = null;
    showResults.value = false;
  }

  void clearSelectedBusiness() {
    selectedBusiness.value = null;
    search.value = null;
    items.clear();
    meta.value = null;
    errorMessage.value = null;
    showResults.value = false;
  }

  void clearSelection() {
    clearSelectedBusiness();
  }
}
