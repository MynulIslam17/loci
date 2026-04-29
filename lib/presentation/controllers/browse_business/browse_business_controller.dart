import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/data/models/busniess/browse_business_response_model.dart';

import '../../../core/enums/category_enum.dart';
import '../../../core/network/network_caller.dart';

class BrowseBusinessController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  List<BrowseBusinessModel> _businesses = [];

  BusinessCategory? _selectedCategory;

  // =====================
  // GETTERS
  // =====================
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BrowseBusinessModel> get businesses => _businesses;
  BusinessCategory? get selectedCategory => _selectedCategory;

  // =====================
  // INIT
  // =====================
  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;

    if (arg != null && arg is BusinessCategory) {
      fetchBusinesses(arg);
    } else {
      fetchBusinesses(null);
    }
  }

  // =====================
  // FETCH BUSINESSES (WITH PARAM)
  // =====================
  Future<void> fetchBusinesses(BusinessCategory? category) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _selectedCategory = category;
      update();

      final queryParams = <String, dynamic>{};

      if (category != null) {
        queryParams["category"] = category.toJson;
      }

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.browseBusinesses,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.isSuccess && response.body != null) {
        final model =
        BrowseBusinessResponseModel.fromJson(response.body!);

        _businesses = model.data;
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

  // =====================
  // CHANGE CATEGORY
  // =====================
  void changeCategory(BusinessCategory? category) {
    fetchBusinesses(category);
  }

  // =====================
  // REFRESH
  // =====================
  Future<void> refreshData() async {
    await fetchBusinesses(_selectedCategory);
  }
}