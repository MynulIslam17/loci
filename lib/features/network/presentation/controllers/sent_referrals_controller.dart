import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/network/data/models/referral_response_model.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

class SentReferralsController extends GetxController {
  SentReferralsController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  final RxList<ReferralModel> _referrals = <ReferralModel>[].obs;
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String? get errorMessage => _errorMessage.value;
  List<ReferralModel> get referrals => List.unmodifiable(_referrals);
  PaginationMeta? get meta => _meta.value;

  int _currentPage = 1;
  static const int _limit = 10;
  String _searchTerm = '';
  Timer? _debounce;

  bool get hasNextPage => meta?.hasNextPage ?? false;
  String get searchTerm => _searchTerm;

  @override
  void onInit() {
    super.onInit();
    fetchSentReferrals();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchTerm = query.trim();
      fetchSentReferrals();
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchTerm = '';
    fetchSentReferrals();
  }

  Future<void> fetchSentReferrals() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    _currentPage = 1;
    _referrals.clear();

    await _loadPage(_currentPage);

    _isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage) return;

    _isLoadingMore.value = true;
    _currentPage++;

    await _loadPage(_currentPage);

    _isLoadingMore.value = false;
  }

  Future<void> _loadPage(int page) async {
    try {
      final result = await _service.getSentReferrals(
        page: page,
        limit: _limit,
        searchTerm: _searchTerm,
      );
      _referrals.addAll(result.data);
      _meta.value = result.meta;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (page > 1) _currentPage--;
    }
  }
}
