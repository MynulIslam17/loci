import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class BrowseBusinessController extends GetxController {
  BrowseBusinessController(this._service);

  final BrowseBusinessService _service;

  final isLoading = false.obs;
  final isPaginationLoading = false.obs;
  final errorMessage = RxnString();

  final businesses = <BrowseBusinessModel>[].obs;

  final selectedCategory = Rxn<BusinessCategory>();

  // ================= PAGINATION =================
  int _currentPage = 1;
  final int _limit = 10;
  final hasNextPage = true.obs;

  bool get hasMore => hasNextPage.value;

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
        hasNextPage.value = true;
        businesses.clear();
      }

      isLoading.value = true;
      errorMessage.value = null;
      selectedCategory.value = category;

      final model = await _service.browseBusinesses(
        page: _currentPage,
        limit: _limit,
        category: category?.toJson,
      );

      businesses.assignAll(model.data);
      hasNextPage.value = model.meta.hasNextPage;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOAD MORE =================
  Future<void> loadMore() async {
    // Also guard on isLoading so a scroll during the first/refresh load can't
    // kick off page 2 before page 1 has arrived.
    if (!hasNextPage.value || isPaginationLoading.value || isLoading.value) {
      return;
    }

    try {
      isPaginationLoading.value = true;
      _currentPage++;

      final model = await _service.browseBusinesses(
        page: _currentPage,
        limit: _limit,
        category: selectedCategory.value?.toJson,
      );

      businesses.addAll(model.data);
      hasNextPage.value = model.meta.hasNextPage;
    } catch (e) {
      _currentPage--; // rollback
    } finally {
      isPaginationLoading.value = false;
    }
  }

  // ================= CHANGE CATEGORY =================
  void changeCategory(BusinessCategory? category) {
    fetchBusinesses(category, isRefresh: true);
  }

  // ================= REFRESH =================
  Future<void> refreshData() async {
    await fetchBusinesses(selectedCategory.value, isRefresh: true);
  }
}
