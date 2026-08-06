import 'package:get/get.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';

class LoginController extends GetxController {
  final AuthService _service;

  LoginController(this._service);

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<bool> login({
    required String email,
    required String password,
    bool isRememberMe = false,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _service.login(email: email, password: password);
      await _service.saveRememberMe(remember: isRememberMe, email: email);
      await Get.find<AuthController>().saveUserData(
        model: result.user,
        token: result.token,
      );
      if (Get.isRegistered<SubscriptionController>()) {
        Get.find<SubscriptionController>().initializeStripe();
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<({bool remember, String? email})> getRememberedPreference() {
    return _service.getRememberMe();
  }
}
