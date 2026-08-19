import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';

class PassResetController extends GetxController {
  final AuthService _service;

  PassResetController(this._service);

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.resetPassword(
        email: email,
        newPassword: newPassword,
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
