import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class ReusableMultipartController extends GetxController {
  ReusableMultipartController(this._service);

  final CommonService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  void reset() {
    _isLoading.value = false;
    _errorMessage.value = null;
  }

  Future<bool> sendMultipartRequest({
    required String url,
    required Map<String, String> fields,
    Map<String, File>? files,
    String method = 'POST',
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      await _service.multipart(
        url: url,
        fields: fields,
        files: files,
        method: method,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
