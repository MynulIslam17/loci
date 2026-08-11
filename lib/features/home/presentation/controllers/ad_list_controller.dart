import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/my_business/data/models/ad_item_model.dart';

class AdListController extends GetxController {
  AdListController(this._service);

  final HomeService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final errorMessage = RxnString();
  final ads = <AdItemModel>[].obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  Future<void> fetchAds({bool showErrorToast = true, bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    errorMessage.value = null;

    try {
      ads.assignAll(await _service.getAds());
      _fetch.endFirstPage();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (!hasFetched) ads.clear();
      if (showErrorToast &&
          errorMessage.value != null &&
          errorMessage.value!.isNotEmpty) {
        SnackbarService.error(errorMessage.value!);
      }
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }
}
