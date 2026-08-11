import 'package:get/get.dart';
import 'package:loci/features/auth/data/services/google_sign_in_service.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';

class LoginController extends GetxController {
  final AuthService _service;
  final GoogleSignInService _googleSignIn;

  LoginController(this._service, this._googleSignIn);

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
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
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Google Sign-In. Returns `true` on success, `false` on error,
  /// `null` if the user cancelled (no toast).
  Future<bool?> loginWithGoogle() async {
    isGoogleLoading.value = true;
    errorMessage.value = null;

    try {
      final idToken = await _googleSignIn.getIdToken();
      if (idToken == null) return null; // cancelled

      final result = await _service.loginWithGoogle(idToken: idToken);
      await _applySession(result);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isGoogleLoading.value = false;
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
