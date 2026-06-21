import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/data/models/raffles/raffles_model.dart';

class RaffleListController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  // ---------------- STATE ----------------
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;

  List<RaffleModel> _raffleList = [];

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasNextPage = true;

  String _searchQuery = '';
  Timer? _searchDebounce;

  // ---------------- GETTERS ----------------
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<RaffleModel> get raffleList => _raffleList;
  bool get hasNextPage => _hasNextPage;
  String get searchQuery => _searchQuery;

  // ---------------- LOADING HELPERS ----------------
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    update();
  }

  void _setPaginationLoading(bool value) {
    if (_isPaginationLoading == value) return;
    _isPaginationLoading = value;
    update();
  }

  // ---------------- SEARCH ----------------
  /// Debounced search — updates the query and refetches from the API.
  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchRaffles(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  String _buildUrl() {
    final params = <String, String>{
      'page': '$_currentPage',
      'limit': '$_limit',
    };
    final query = _searchQuery.trim();
    if (query.isNotEmpty) params['search'] = query;

    final qs = params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '${AppUrl.raffles}?$qs';
  }

  // ---------------- FETCH RAFFLES ----------------
  Future<void> fetchRaffles({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _raffleList.clear();
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _network.getRequest(url: _buildUrl());

      if (!response.isSuccess || response.body == null) {
        _errorMessage =
            response.errorMessage ?? "Failed to load raffles";
        SnackbarService.error(_errorMessage!);
        return;
      }

      final model = RaffleListResponseModel.fromJson(response.body!);

      _raffleList.addAll(model.raffles);

      _hasNextPage = model.meta.hasNextPage;
      _currentPage++;
    } catch (e) {
      _errorMessage = "Something went wrong";
      SnackbarService.error(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- LOAD MORE ----------------
  Future<void> loadMoreRaffles() async {
    if (_isPaginationLoading || !_hasNextPage || _isLoading) return;

    _setPaginationLoading(true);

    try {
      final response = await _network.getRequest(url: _buildUrl());

      if (!response.isSuccess || response.body == null) {
        SnackbarService.error(
          response.errorMessage ?? "Failed to load more raffles",
        );
        return;
      }

      final model = RaffleListResponseModel.fromJson(response.body!);

      _raffleList.addAll(model.raffles);

      _hasNextPage = model.meta.hasNextPage;
      _currentPage++;
    } catch (e) {
      SnackbarService.error("Something went wrong");
    } finally {
      _setPaginationLoading(false);
    }
  }

  // ---------------- REFRESH ----------------
  Future<void> refreshRaffles() async {
    await fetchRaffles(isRefresh: true);
  }
}
