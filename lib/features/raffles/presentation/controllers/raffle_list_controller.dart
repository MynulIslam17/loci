import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';

class RaffleListController extends GetxController {
  RaffleListController(this._service);

  final RafflesService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isPaginationLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  final RxList<RaffleModel> _raffleList = <RaffleModel>[].obs;

  int _currentPage = 1;
  final int _limit = 10;
  bool _hasNextPage = true;

  String _searchQuery = '';
  Timer? _searchDebounce;

  bool get isLoading => _isLoading.value;
  bool get isPaginationLoading => _isPaginationLoading.value;
  String? get errorMessage => _errorMessage.value;
  List<RaffleModel> get raffleList => _raffleList;
  bool get hasNextPage => _hasNextPage;
  String get searchQuery => _searchQuery;

  void _setLoading(bool value) {
    if (_isLoading.value == value) return;
    _isLoading.value = value;
  }

  void _setPaginationLoading(bool value) {
    if (_isPaginationLoading.value == value) return;
    _isPaginationLoading.value = value;
  }

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

  Future<void> fetchRaffles({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _raffleList.clear();
    }

    _setLoading(true);
    _errorMessage.value = null;

    try {
      final model = await _service.getRaffles(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );

      _raffleList.addAll(model.raffles);
      _hasNextPage = model.meta.hasNextPage;
      _currentPage++;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      SnackbarService.error(_errorMessage.value!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreRaffles() async {
    if (_isPaginationLoading.value || !_hasNextPage || _isLoading.value) return;

    _setPaginationLoading(true);

    try {
      final model = await _service.getRaffles(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );

      _raffleList.addAll(model.raffles);
      _hasNextPage = model.meta.hasNextPage;
      _currentPage++;
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setPaginationLoading(false);
    }
  }

  Future<void> refreshRaffles() async {
    await fetchRaffles(isRefresh: true);
  }
}
