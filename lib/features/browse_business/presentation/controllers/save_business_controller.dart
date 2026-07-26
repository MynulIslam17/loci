import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class SaveBusinessController extends GetxController {
  SaveBusinessController(this._service);

  final BrowseBusinessService _service;

  final loadingId = RxnString();
  final errorMessage = RxnString();
  final successMessage = RxnString();

  bool isLoading(String id) => loadingId.value == id;

  Future<bool> saveBusiness(String businessId) async {
    loadingId.value = businessId;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.saveBusiness(businessId);
      SnackbarService.success(successMessage.value!);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      SnackbarService.error(errorMessage.value!);
      return false;
    } finally {
      loadingId.value = null;
    }
  }

  void reset() {
    loadingId.value = null;
    errorMessage.value = null;
    successMessage.value = null;
  }
}
