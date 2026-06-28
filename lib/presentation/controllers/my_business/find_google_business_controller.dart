import 'package:loci/core/constants/app_url.dart';

import '../../../data/models/busniess/find_business_response.dart';
import '../common/base_paginated_controller.dart';

class FindGoogleBusinessController extends BasePaginationController<Business> {
  String? search;
  Business? selectedBusiness;
  bool showResults = false;

  @override
  bool get shouldFetchOnInit => false;

  @override
  String get url => AppUrl.findGoogleBusiness;

  @override
  Business Function(Map<String, dynamic>) get fromJson => Business.fromJson;

  @override
  Map<String, dynamic>? get queryParams =>
      search != null && search!.isNotEmpty ? {'search': search} : null;

  void searchBusinesses(String query) {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      search = null;
      items = [];
      meta = null;
      errorMessage = null;
      showResults = false;
      clearSelection();
      return;
    }

    if (selectedBusiness != null) {
      selectedBusiness = null;
    }

    search = trimmed;
    showResults = true;
    fetchPage();
  }

  void selectBusiness(Business business) {
    selectedBusiness = business;
    search = null;
    items = [];
    meta = null;
    errorMessage = null;
    showResults = false;
    update();
  }

  void clearSelectedBusiness() {
    selectedBusiness = null;
    search = null;
    items = [];
    meta = null;
    errorMessage = null;
    showResults = false;
    update();
  }

  void clearSelection() {
    clearSelectedBusiness();
  }
}
