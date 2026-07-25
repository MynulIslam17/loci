import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/my_business/data/models/ad_item_model.dart';

class AdListController extends GetxController {
  AdListController(this._service);

  final HomeService _service;

  // Start in loading state so the home banner shows a shimmer on first build
  // instead of briefly flashing the fallback while /ads is in flight.
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final ads = <AdItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  Future<void> fetchAds({bool showErrorToast = true}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      ads.assignAll(await _service.getAds());
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      ads.clear();
      if (showErrorToast &&
          errorMessage.value != null &&
          errorMessage.value!.isNotEmpty) {
        SnackbarService.error(errorMessage.value!);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
