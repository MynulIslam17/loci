import 'package:get/get.dart';
import 'package:loci/core/di/bindings/app_bindings.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/core/services/chat_socket_service.dart';
import 'package:loci/core/services/stripe_service.dart';
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

  // Static (survives the dependency wipe below) so a burst of 401s all calling
  // logout() only tears down once.
  static bool _loggingOut = false;

  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      await _performLogout();
    } finally {
      _loggingOut = false;
    }
  }

  Future<void> _performLogout() async {
    // 1. Gracefully close realtime + clear the persisted session first.
    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().disconnect();
    }
    await _service.clearSession();

    // 2. Clear reactive session state for anything still mounted this frame.
    accessTokenRx.value = null;
    userModelRx.value = null;
    roleRx.value = null;

    // 3. Wipe EVERY GetX dependency and rebuild the app-permanent graph from
    // scratch. This is the single guarantee that no controller or service
    // holds the previous user's data or a cached API response:
    //   - permanent controllers (subscription, votes, QR…) are recreated fresh;
    //   - route / fenix controllers are rebuilt by their bindings on the next
    //     visit, so their onInit refetches for the new user;
    //   - stateless repos/services are re-wired to the fresh NetworkCaller.
    // Done BEFORE navigating so the login route's binding resolves fresh deps.
    Get.deleteAll(force: true);
    AppBindings().dependencies();

    // 4. Reset navigation to the login screen (fresh dependency graph in place).
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
