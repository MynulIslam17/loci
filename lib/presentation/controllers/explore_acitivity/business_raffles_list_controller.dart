import 'package:get/get.dart';

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../data/models/raffles/raffles_model.dart';

class BusinessRafflesListController extends GetxController {
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  List<RaffleModel> _raffleList = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 3;

  // --- Getters
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<RaffleModel> get raffleList => _raffleList;
  bool get hasMore => _hasNextPage;

  // --- Fetch Raffles
  Future<void> fetchRaffles({bool isRefresh = false, required String businessId}) async {
    if (_isLoading) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;

    }

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final url = '${AppUrl.createRaffle}?page=$_currentPage&limit=$_limit&businessId=$businessId';

      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = RaffleListResponseModel.fromJson(response.body!);

        if (isRefresh) {
          _raffleList = model.raffles;
        } else {
          _raffleList.addAll(model.raffles);
        }

        _hasNextPage = model.meta.hasNextPage;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load raffles';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      update();
    }
  }

  // --- Load Next Page (Pagination)
  Future<void> loadMoreRaffles({required String businessId}) async {
    // Lock: Prevent pagination if already loading or no more data
    if (!_hasNextPage || _isPaginationLoading || _isLoading) return;

    _isPaginationLoading = true;
    _currentPage++;
    update();

    try {
      final url = '${AppUrl.createRaffle}?page=$_currentPage&limit=$_limit&businessId=$businessId';

      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = RaffleListResponseModel.fromJson(response.body!);
        _raffleList.addAll(model.raffles);
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _currentPage--; // Rollback page on failure
      }
    } catch (e) {
      _currentPage--; // Rollback page on error
      _errorMessage = 'Pagination error: $e';
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  // --- Reset Controller
  void reset() {
    _isLoading = false;
    _isPaginationLoading = false;
    _errorMessage = null;
    _raffleList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    update();
  }
}