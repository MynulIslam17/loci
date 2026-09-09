import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/features/auth/data/auth_api_exception.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
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
      final result = await _appleSession();
      if (result == null) {
        return false; // User cancelled
      }

      await _applySession(result);
      return true;
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
      return false;
    } finally {
      isAppleLoading.value = false;
    }
  }

  /// Runs the native Apple sheet and exchanges the credential for a session.
  /// Returns `null` if the user cancelled.
  ///
  /// A 401 means the identity token was expired, malformed or issued for the
  /// wrong audience. Re-running the native flow mints a fresh one, so retry
  /// once before surfacing the failure.
  Future<({UserModel user, String token})?> _appleSession() async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final credential = await _socialAuth.getAppleCredential();
      if (credential == null) return null;

      try {
        return await _service.loginWithApple(
          identityToken: credential.identityToken,
          fullName: credential.fullName,
        );
      } on AuthApiException catch (e) {
        if (e.statusCode != 401 || attempt == 1) rethrow;
      }
    }
    return null;
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
