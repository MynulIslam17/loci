import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class CreateAdController extends GetxController {
  CreateAdController(this._service);

  final MyBusinessService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  Future<bool> submitAd({
    required String title,
    required DateTime endDate,
    required File image,
    String? businessName,
    String? location,
    DateTime? startDate,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      successMessage.value = null;

      successMessage.value = await _service.submitAd(
        title: title,
        endDate: endDate,
        image: image,
        businessName: businessName,
        location: location,
        startDate: startDate,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
