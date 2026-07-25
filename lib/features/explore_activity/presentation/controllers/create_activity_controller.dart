import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class CreateActivityController extends GetxController {
  CreateActivityController(this._service);

  final MyBusinessService _service;

  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }

  Future<bool> createActivity({
    required String url,
    required Map<String, String> body,
    Map<String, File>? files,
  }) async {
    try {
      setLoading(true);

      message.value = await _service.createActivity(
        url: url,
        body: body,
        files: files,
      );
      return true;
    } catch (e) {
      message.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
