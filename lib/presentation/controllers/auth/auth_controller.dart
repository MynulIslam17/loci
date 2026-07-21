import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/services/chat_socket_service.dart';
import '../../../core/services/stripe_service.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../nav_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  String? accessToken;
  String? role;
  UserModel? userModel;

  @override
  void onInit() {
    super.onInit();

    loadUserData();
  }

  Future<void> saveUserData({
    required UserModel model,
    required String token,
  }) async {
    await _repository.saveUserData(model: model, token: token);
    accessToken = token;
    userModel = model;
    role = model.role;
    update();
    _onAuthenticated();
  }

  Future<void> loadUserData() async {
    final data = await _repository.loadUserData();
    accessToken = data.token;
    userModel = data.user;
    role = data.role;
    update();
    if (accessToken != null && accessToken!.isNotEmpty) _onAuthenticated();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _repository.updateUser(updatedUser);
    userModel = updatedUser;
    update();
  }

  Future<void> logout() async {
    await _repository.clearUserData();

    accessToken = null;
    userModel = null;
    role = null;
    update();

    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().disconnect();
    }

    Get.find<NavController>().changeIndex(0);

    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => accessToken != null;

  /// Runs once we have a valid token (login or app-start with a saved session).
  /// Connectivity-dependent services are started here — never on the login
  /// screen — so a cold start or an unreachable server can't spam errors before
  /// the user has even signed in.
  void _onAuthenticated() {
    // Realtime chat connection.
    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().connect();
    }
    // Fetch the Stripe publishable key (only needed for checkout, which is
    // reachable only when logged in). Fire-and-forget; checkout re-inits lazily.
    if (Get.isRegistered<StripeService>()) {
      Get.find<StripeService>().init();
    }
  }
}