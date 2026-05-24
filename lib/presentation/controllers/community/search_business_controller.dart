import 'dart:async';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/data/models/busniess/browse_business_response_model.dart';

class SearchBusinessController extends GetxController {
  bool _isLoading = false;
  bool _searchDone = false;
  String? _errorMessage;
  List<BrowseBusinessModel> _businesses = [];
  Timer? _debounce;

  bool get isLoading => _isLoading;
  bool get searchDone => _searchDone;
  String? get errorMessage => _errorMessage;
  List<BrowseBusinessModel> get businesses => _businesses;

  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _businesses = [];
      _errorMessage = null;
      _searchDone = false;
      update();
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => search(query.trim()),
    );
  }

  Future<void> search(String query) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.searchBusinesses(query),
      );

      if (response.isSuccess && response.body != null) {
        final parsed = BrowseBusinessResponseModel.fromJson(
          response.body as Map<String, dynamic>,
        );
        _businesses = parsed.data;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to search businesses';
        _businesses = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _businesses = [];
    } finally {
      _isLoading = false;
      _searchDone = true;
      update();
    }
  }

  void reset() {
    _debounce?.cancel();
    _businesses = [];
    _isLoading = false;
    _searchDone = false;
    _errorMessage = null;
    update();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
