import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/data/models/busniess/browse_business_response_model.dart';

import '../../../core/enums/category_enum.dart';
import '../../../core/network/network_caller.dart';

class BrowseBusinessController extends GetxController {
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;

  List<BrowseBusinessModel> _businesses = [];

  BusinessCategory? _selectedCategory;

  // ================= PAGINATION =================
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasNextPage = true;

  // ================= GETTERS =================
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;

  List<BrowseBusinessModel> get businesses => _businesses;
  BusinessCategory? get selectedCategory => _selectedCategory;

  bool get hasMore => _hasNextPage;

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;

    if (arg != null && arg is BusinessCategory) {
      fetchBusinesses(arg, isRefresh: true);
    } else {
      fetchBusinesses(null, isRefresh: true);
    }
  }

  // ================= FETCH FIRST PAGE =================
  Future<void> fetchBusinesses(
      BusinessCategory? category, {
        bool isRefresh = false,
      }) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        _hasNextPage = true;
        _businesses.clear();
      }

      _isLoading = true;
      _errorMessage = null;
      _selectedCategory = category;
      update();

      final queryParams = <String, dynamic>{
        "page": _currentPage,
        "limit": _limit,
      };

      if (category != null) {
        queryParams["category"] = category.toJson;
      }

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.browseBusinesses,
        queryParams: queryParams,
      );

      if (response.isSuccess && response.body != null) {
        final model =
        BrowseBusinessResponseModel.fromJson(response.body!);

        _businesses = model.data;
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load businesses";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ================= LOAD MORE =================
  Future<void> loadMore() async {
    if (!_hasNextPage || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      _currentPage++;
      update();

      final queryParams = <String, dynamic>{
        "page": _currentPage,
        "limit": _limit,
      };

      if (_selectedCategory != null) {
        queryParams["category"] = _selectedCategory!.toJson;
      }

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.browseBusinesses,
        queryParams: queryParams,
      );

      if (response.isSuccess && response.body != null) {
        final model =
        BrowseBusinessResponseModel.fromJson(response.body!);

        _businesses.addAll(model.data);
        _hasNextPage = model.meta.hasNextPage;
      } else {
        _currentPage--; // rollback
      }
    } catch (e) {
      _currentPage--; // rollback
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  // ================= CHANGE CATEGORY =================
  void changeCategory(BusinessCategory? category) {
    fetchBusinesses(category, isRefresh: true);
  }

  // ================= REFRESH =================
  Future<void> refreshData() async {
    await fetchBusinesses(_selectedCategory, isRefresh: true);
  }
}