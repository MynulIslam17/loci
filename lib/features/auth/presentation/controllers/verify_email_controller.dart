import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';

class VerifyEmailController extends GetxController {
  final AuthService _service;

  VerifyEmailController(this._service);

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  Future<bool> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      final result = await _service.verifySignupOtp(email: email, otp: otp);
      successMessage.value = result.message;
      if (result.user != null && result.token != null) {
        await Get.find<AuthController>().saveUserData(
          model: result.user!,
          token: result.token!,
        );
      }
      return true;
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyForgotOtp({
    required String email,
    required String otp,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.verifyForgotOtp(
        email: email,
        otp: otp,
      );
      return true;
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
