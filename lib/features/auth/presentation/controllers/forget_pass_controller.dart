import 'package:get/get.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';

class ForgetPassController extends GetxController {
  final AuthService _service;

  ForgetPassController(this._service);

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  Future<bool> sendForgotOtp({required String email}) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.sendForgotOtp(email: email);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
