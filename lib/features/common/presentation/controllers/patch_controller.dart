import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class PatchController extends GetxController {
  PatchController(this._service);

  final CommonService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  Future<bool> patchData({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      await _service.patch(url: url, body: body);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
