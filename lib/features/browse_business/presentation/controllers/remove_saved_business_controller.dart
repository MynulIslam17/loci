import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class RemoveSavedBusinessController extends GetxController {
  RemoveSavedBusinessController(this._service);

  final BrowseBusinessService _service;

  final loadingId = RxnString();

  bool isLoading(String id) => loadingId.value == id;

  Future<bool> removeBusiness(String businessId) async {
    loadingId.value = businessId;

    try {
      final message = await _service.removeSavedBusiness(businessId);
      SnackbarService.success(message);
      return true;
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      loadingId.value = null;
    }
  }
}
