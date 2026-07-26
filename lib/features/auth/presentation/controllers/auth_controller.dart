import 'package:get/get.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/core/services/chat_socket_service.dart';
import 'package:loci/core/services/stripe_service.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';
import 'package:loci/features/qr_code/presentation/controllers/get_my_qr_controller.dart';
import 'package:loci/routes/app_routes.dart';

/// Session / auth shell controller. UI listens via Obx.
class AuthController extends GetxController {
  final AuthService _service;

  AuthController(this._service);

  /// Reactive fields. Getters preserve the existing public API used outside
  /// this feature (core / other features read `.accessToken`, `.userModel`, etc.).
  final Rxn<String> accessTokenRx = Rxn<String>();
  final Rxn<String> roleRx = Rxn<String>();
  final Rxn<UserModel> userModelRx = Rxn<UserModel>();

  String? get accessToken => accessTokenRx.value;
  String? get role => roleRx.value;
  UserModel? get userModel => userModelRx.value;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> saveUserData({
    required UserModel model,
    required String token,
  }) async {
    await _service.saveSession(model: model, token: token);
    accessTokenRx.value = token;
    userModelRx.value = model;
    roleRx.value = model.role;
    _onAuthenticated();
  }

  Future<void> loadUserData() async {
    final data = await _service.loadSession();
    accessTokenRx.value = data.token;
    userModelRx.value = data.user;
    roleRx.value = data.role;
    if (accessToken != null && accessToken!.isNotEmpty) _onAuthenticated();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _service.updateUser(updatedUser);
    userModelRx.value = updatedUser;
  }

  Future<void> logout() async {
    await _service.clearSession();

    accessTokenRx.value = null;
    userModelRx.value = null;
    roleRx.value = null;

    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().disconnect();
    }

    // Drop the session-cached QR so the next signed-in user never sees it.
    if (Get.isRegistered<GetMyQrCodeController>()) {
      Get.find<GetMyQrCodeController>().clear();
    }

    if (Get.isRegistered<NavController>()) {
      Get.find<NavController>().changeIndex(0);
    }
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => accessToken != null;

  void _onAuthenticated() {
    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().connect();
    }
    if (Get.isRegistered<StripeService>()) {
      Get.find<StripeService>().init();
    }
  }
}
