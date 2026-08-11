import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class SaveBusinessController extends GetxController {
  SaveBusinessController(this._service);

  final BrowseBusinessService _service;

  final loadingId = RxnString();
  final errorMessage = RxnString();
  final successMessage = RxnString();

  /// Local overrides of the saved state, keyed by businessId. Lets a card or
  /// button flip between "Saved"/"Add to List" after a save/unsave without
  /// mutating the immutable business models. A missing entry means "use the
  /// state the server sent" (`item.isSaved`).
  final _saveOverrides = <String, bool>{}.obs;

  bool isLoading(String id) => loadingId.value == id;

  /// Effective saved state: the local override if we have one, otherwise the
  /// [serverSaved] flag that came with the business.
  bool isSaved(String id, bool serverSaved) =>
      _saveOverrides[id] ?? serverSaved;

  Future<bool> saveBusiness(String businessId) async {
    loadingId.value = businessId;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.saveBusiness(businessId);
      _saveOverrides[businessId] = true;
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

  Future<bool> unsaveBusiness(String businessId) async {
    loadingId.value = businessId;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.removeSavedBusiness(businessId);
      _saveOverrides[businessId] = false;
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
    _saveOverrides.clear();
  }
}
