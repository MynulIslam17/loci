import 'package:get/get.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';

class SignupController extends GetxController {
  final AuthService _service;

  SignupController(this._service);

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String zipCode,
    required String dateOfBirth,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.signup(
        name: name,
        email: email,
        password: password,
        zipCode: zipCode,
        dateOfBirth: dateOfBirth,
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
