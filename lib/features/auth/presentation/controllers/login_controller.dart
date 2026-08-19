import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/domain/services/social_auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';

class LoginController extends GetxController {
  final AuthService _service;
  final SocialAuthService _socialAuth;

  LoginController(this._service, [SocialAuthService? socialAuth])
      : _socialAuth = socialAuth ?? SocialAuthService();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isAppleLoading = false.obs;
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
      await _applySession(result);
      return true;
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginWithGoogle() async {
    isGoogleLoading.value = true;
    errorMessage.value = null;

    try {
      final idToken = await _socialAuth.getGoogleIdToken();
      if (idToken == null) {
        return false; // User cancelled
      }

      final result = await _service.loginWithGoogle(idToken: idToken);
      await _applySession(result);
      return true;
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
      return false;
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<bool> loginWithApple() async {
    isAppleLoading.value = true;
    errorMessage.value = null;

    try {
      final identityToken = await _socialAuth.getAppleIdentityToken();
      if (identityToken == null) {
        return false; // User cancelled
      }

      final result = await _service.loginWithApple(identityToken: identityToken);
      await _applySession(result);
      return true;
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
      return false;
    } finally {
      isAppleLoading.value = false;
    }
  }

  Future<void> _applySession(({dynamic user, String token}) result) async {
    await Get.find<AuthController>().saveUserData(
      model: result.user,
      token: result.token,
    );
    if (Get.isRegistered<SubscriptionController>()) {
      Get.find<SubscriptionController>().initializeStripe();
    }
  }

  Future<({bool remember, String? email})> getRememberedPreference() {
    return _service.getRememberMe();
  }
}
