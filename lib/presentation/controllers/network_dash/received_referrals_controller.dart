import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/referral/referral_response_model.dart';

class ReceivedReferralsController extends GetxController {
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;

  List<ReferralModel> referrals = [];
  PaginationMeta? meta;

  int _currentPage = 1;
  static const int _limit = 10;
  String _searchTerm = '';
  Timer? _debounce;

  final ScrollController scrollController = ScrollController();

  bool get hasNextPage => meta?.hasNextPage ?? false;
  String get searchTerm => _searchTerm;

  @override
  void onInit() {
    super.onInit();
    fetchReceivedReferrals();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 && !isLoadingMore && hasNextPage) {
      loadMore();
    }
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchTerm = query.trim();
      fetchReceivedReferrals();
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchTerm = '';
    fetchReceivedReferrals();
  }

  Future<void> fetchReceivedReferrals() async {
    isLoading = true;
    errorMessage = null;
    _currentPage = 1;
    referrals = [];
    update();

    await _loadPage(_currentPage);

    isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage) return;

    isLoadingMore = true;
    _currentPage++;
    update();

    await _loadPage(_currentPage);

    isLoadingMore = false;
    update();
  }

  Future<void> _loadPage(int page) async {
    try {
      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.receiveReferral,
        queryParams: {
          'page': page,
          'limit': _limit,
          if (_searchTerm.isNotEmpty) 'searchTerm': _searchTerm,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result = ReferralResponse.fromJson(response.body!);
        referrals = [...referrals, ...result.data];
        meta = result.meta;
      } else {
        errorMessage = response.body?['message'] ?? 'Failed to load referrals';
        if (page > 1) _currentPage--;
      }
    } catch (e) {
      errorMessage = e.toString();
      if (page > 1) _currentPage--;
    }
  }
}
