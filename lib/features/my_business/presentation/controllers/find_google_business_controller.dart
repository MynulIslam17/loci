import 'dart:async';

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

  /// Wait for a pause in typing before searching (one request, not one per
  /// keystroke).
  static const Duration searchDebounce = Duration(milliseconds: 350);
  Timer? _debounce;

  /// Bumped on every new search / selection so a slow, older response can't
  /// overwrite newer results (or reopen the list after a selection).
  int _generation = 0;

  bool get hasNextPage => meta.value?.hasNextPage ?? false;
  int get currentPage => meta.value?.page ?? 1;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    _debounce?.cancel();
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
    final int generation = _generation;
    errorMessage.value = null;
    _setLoading(true);

    try {
      final result = await _service.findGoogleBusinesses(
        page: page,
        limit: 10,
        search: search.value,
      );
      if (generation != _generation) return;
      items.assignAll(result.data);
      meta.value = result.meta;
    } catch (e) {
      if (generation != _generation) return;
      errorMessage.value = _friendlyError(e);
      items.clear();
    } finally {
      if (generation == _generation) _setLoading(false);
    }
  }

  static String _friendlyError(Object e) {
    final String text = e.toString().replaceFirst('Exception: ', '').trim();
    final bool technical =
        text.isEmpty ||
        text.length > 160 ||
        RegExp(
          r'error:|exception|null|socket|[{}<>]|status ?code',
          caseSensitive: false,
        ).hasMatch(text);
    return technical ? 'Couldn\'t search businesses. Please try again.' : text;
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasNextPage || isLoading.value) return;

    _setLoadingMore(true);

    final int generation = _generation;
    try {
      final result = await _service.findGoogleBusinesses(
        page: currentPage + 1,
        limit: 10,
        search: search.value,
      );
      if (generation != _generation) return;
      items.addAll(result.data);
      meta.value = result.meta;
    } catch (e) {
      if (generation != _generation) return;
      errorMessage.value = _friendlyError(e);
    } finally {
      _setLoadingMore(false);
    }
  }

  void searchBusinesses(String query) {
    final trimmed = query.trim();
    _debounce?.cancel();
    _generation++;

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
    isLoading.value = true; // show the spinner while the user is typing
    _debounce = Timer(searchDebounce, fetchPage);
  }

  void selectBusiness(Business business) {
    _debounce?.cancel();
    _generation++;
    isLoading.value = false;
    selectedBusiness.value = business;
    search.value = null;
    items.clear();
    meta.value = null;
    errorMessage.value = null;
    showResults.value = false;
  }

  void clearSelectedBusiness() {
    _debounce?.cancel();
    _generation++;
    isLoading.value = false;
    isLoadingMore.value = false;
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
