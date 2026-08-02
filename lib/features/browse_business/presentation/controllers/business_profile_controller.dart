import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class BusinessProfileController extends GetxController {
  BusinessProfileController(this._service);

  final BrowseBusinessService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final errorMessage = RxnString();
  final business = Rxn<BrowseBusinessModel>();

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;

  Future<void> getBusinessProfile(String businessId, {bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    errorMessage.value = null;

    try {
      business.value = await _service.getBusinessProfile(businessId);
      _fetch.endFirstPage();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }
}
