import 'package:get/get.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class PostController extends GetxController {
  PostController(this._service);

  final CommonService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<String> _token = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  String? get getToken => _token.value;

  Future<bool> postData({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      await _service.post(url: url, body: body);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> postWithTempToken({
    required String url,
    required Map<String, dynamic> body,
    String? tempToken,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      final response = await _service.post(
        url: url,
        body: body,
        overrideToken: tempToken ?? _token.value,
      );

      final data = response['data'];
      if (data is Map && data['token'] != null) {
        _token.value = data['token']?.toString();
      }
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
