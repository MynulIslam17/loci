import 'package:get/get.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';

class BusinessProfileController extends GetxController {
  BusinessProfileController(this._service);

  final BrowseBusinessService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final business = Rxn<BrowseBusinessModel>();

  Future<void> getBusinessProfile(String businessId) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      business.value = await _service.getBusinessProfile(businessId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
