import 'package:get/get.dart';
import 'package:loci/core/di/bindings/app_bindings.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/core/services/stripe_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
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

  /// Incremented when the avatar changes so CachedNetworkImage can bust cache
  /// even if the URL string stays the same.
  final RxInt avatarRevision = 0.obs;

  String? get accessToken => accessTokenRx.value;
  String? get role => roleRx.value;
  UserModel? get userModel => userModelRx.value;

  // ── Role helpers ──────────────────────────────────────────────────────────
  /// Roles allowed to use subscription features (buy/manage a plan).
  static const _subscriptionRoles = {'business_owner', 'admin'};

  bool get isBusinessOwner => role == 'business_owner';
  bool get isAdmin => role == 'admin';

  /// A plain member (role `user`) — cannot access subscription features until
  /// they claim/create a business and are promoted to `business_owner`.
  bool get isMember => !isBusinessOwner && !isAdmin;

  /// Gate for the whole subscription feature (drawer entry, settings entry,
  /// purchase). Reactive — reading it inside an Obx updates when the role does.
  bool get canAccessSubscription => _subscriptionRoles.contains(role);

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
    try {
      final data = await _service.loadSession();
      accessTokenRx.value = data.token;
      userModelRx.value = data.user;
      roleRx.value = data.role;
      if (accessToken != null && accessToken!.trim().isNotEmpty) {
        _onAuthenticated();
      }
    } catch (e) {
      // Non-fatal exception handling during session initialization
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final previousAvatar = userModel?.avatar;
    await _service.updateUser(updatedUser);
    userModelRx.value = updatedUser;
    if (updatedUser.avatar != previousAvatar) {
      avatarRevision.value++;
    }
  }

  /// Bump when the avatar file at the same URL was replaced (cache bust).
  void bumpAvatarRevision() => avatarRevision.value++;

  /// Re-fetches the current user from the backend and updates the session.
  /// Call after actions that can change the role — e.g. claiming a business
  /// promotes a member to business_owner, unlocking subscriptions.
  Future<void> refreshUser() async {
    try {
      final user = await _service.getMe();
      userModelRx.value = user;
      roleRx.value = user.role;
    } catch (_) {
      // Non-fatal — keep the existing session on failure.
    }
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
    // 1. Best-effort server logout before clearing local session.
    await _service.logoutRemote();

    // 2. Gracefully close realtime + clear the persisted session and local chat/nav storage.
    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().disconnect();
    }
    if (Get.isRegistered<HiveStorageService>()) {
      await Get.find<HiveStorageService>().wipeOnLogout();
    }
    await _service.clearSession();

    // 3. Clear reactive session state for anything still mounted this frame.
    accessTokenRx.value = null;
    userModelRx.value = null;
    roleRx.value = null;

    // 4. Wipe EVERY GetX dependency and rebuild the app-permanent graph from
    // scratch. This is the single guarantee that no controller or service
    // holds the previous user's data or a cached API response:
    //   - permanent controllers (subscription, votes, QR…) are recreated fresh;
    //   - route / fenix controllers are rebuilt by their bindings on the next
    //     visit, so their onInit refetches for the new user;
    //   - stateless repos/services are re-wired to the fresh NetworkCaller.
    // Done BEFORE navigating so the login route's binding resolves fresh deps.
    Get.deleteAll(force: true);
    AppBindings().dependencies();

    // 5. Reset navigation to the login screen (fresh dependency graph in place).
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => accessToken != null && accessToken!.trim().isNotEmpty;

  void _onAuthenticated() {
    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().connect();
    }
    if (Get.isRegistered<StripeService>()) {
      Get.find<StripeService>().init();
    }
  }
}
