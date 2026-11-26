import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:loci/core/network/network_setup.dart' as network;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';
import 'package:loci/core/di/bindings/app_bindings.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/push_notification/domain/services/push_notification_service.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/loading_dialog.dart';

/// Session / auth shell controller. UI listens via Obx.
class AuthController extends GetxController {
  final AuthService _service;

  AuthController(
    this._service, {
    Future<bool> Function()? refreshAccessToken,
    DateTime Function()? clock,
    this.observeLifecycle = true,
  }) : _refreshAccessToken = refreshAccessToken ?? network.refreshAccessToken,
       _now = clock ?? DateTime.now;

  final Future<bool> Function() _refreshAccessToken;
  final DateTime Function() _now;

  /// Re-check the role whenever the app comes back to the foreground.
  final bool observeLifecycle;
  AppLifecycleListener? _lifecycle;
  Future<bool>? _userRefresh;
  DateTime? _lastUserRefresh;

  /// A role change made on the server (e.g. an admin approving a business
  /// claim) is picked up at most this long after the app is resumed.
  static const Duration resumeRefreshInterval = Duration(seconds: 30);

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
    if (observeLifecycle) {
      try {
        _lifecycle = AppLifecycleListener(
          onResume: () => unawaited(refreshUser(force: false)),
        );
      } catch (_) {
        // No widgets binding (plain unit tests).
      }
    }
  }

  @override
  void onClose() {
    _lifecycle?.dispose();
    super.onClose();
  }

  Future<void> saveUserData({
    required UserModel model,
    required String token,
    String? refreshToken,
  }) async {
    await _service.saveSession(
      model: model,
      token: token,
      refreshToken: refreshToken,
    );
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
        // The stored role can be stale (e.g. a claim was approved while the
        // app was closed) — confirm it with the server.
        unawaited(refreshUser());
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

  /// Re-fetches the current user from the backend and updates the session
  /// (persisted, so it survives a restart). Returns true when the role
  /// changed. Called on launch, on resume, when the business screens open and
  /// when a claim-approved notification arrives — an admin approves a claim
  /// long after it was submitted, so checking only after submitting is not
  /// enough.
  ///
  /// [force] false skips the call if the user was refreshed recently.
  /// Concurrent calls share one request.
  Future<bool> refreshUser({bool force = true}) {
    if (!isLoggedIn) return Future<bool>.value(false);
    final DateTime? last = _lastUserRefresh;
    if (!force &&
        last != null &&
        _now().difference(last) < resumeRefreshInterval) {
      return Future<bool>.value(false);
    }
    return _userRefresh ??= _refreshUserNow().whenComplete(() {
      _userRefresh = null;
    });
  }

  Future<bool> _refreshUserNow() async {
    try {
      final user = await _service.getMe();
      _lastUserRefresh = _now();
      final String? previousRole = role;
      // The access token embeds the role it was issued with; replace it
      // FIRST, so screens reacting to the new role (subscription status,
      // business list) already call the API with a token carrying that role.
      final String? tokenRole = jwtRole(accessToken);
      if (tokenRole != null && tokenRole != user.role) {
        await _refreshAccessToken();
      }
      // Only publish real changes: every user/role emission is a "session
      // change" that clears and reloads the subscription state — doing that
      // on each resume (e.g. returning from the App Store sheet mid-purchase)
      // makes screens flicker and races the purchase.
      final UserModel? current = userModel;
      if (current == null ||
          jsonEncode(current.toJson()) != jsonEncode(user.toJson())) {
        userModelRx.value = user;
      }
      if (role != user.role) roleRx.value = user.role;
      return previousRole != user.role;
    } catch (_) {
      // Non-fatal — keep the existing session on failure.
      return false;
    }
  }

  /// The `role` claim of a JWT, or null when it can't be read.
  static String? jwtRole(String? token) {
    final List<String> parts = (token ?? '').split('.');
    if (parts.length != 3) return null;
    try {
      final Object? payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final Object? role = payload is Map ? payload['role'] : null;
      return role is String ? role : null;
    } catch (_) {
      return null;
    }
  }

  // Static (survives the dependency wipe below) so a burst of 401s all calling
  // logout() only tears down once.
  static bool _loggingOut = false;

  Future<void> logout({bool showLoader = true}) async {
    if (_loggingOut) return;
    _loggingOut = true;

    if (showLoader) {
      showLoadingDialog(message: 'Signing out...');
    }

    try {
      await _performLogout();
    } finally {
      if (showLoader) {
        hideLoadingDialog();
      }
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
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().clearTokenCache();
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
    final prefs = Get.isRegistered<SharedPreferences>()
        ? Get.find<SharedPreferences>()
        : null;
    final connectivity = Get.isRegistered<ConnectivityService>()
        ? Get.find<ConnectivityService>()
        : null;

    Get.deleteAll(force: true);

    if (prefs != null) {
      Get.put<SharedPreferences>(prefs, permanent: true);
    }
    if (connectivity != null) {
      Get.put<ConnectivityService>(connectivity, permanent: true);
    }
    AppBindings().dependencies();

    // 5. Reset navigation to the login screen (fresh dependency graph in place).
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => accessToken != null && accessToken!.trim().isNotEmpty;

  void _onAuthenticated() {
    if (Get.isRegistered<ChatSocketService>()) {
      Get.find<ChatSocketService>().connect();
    }
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().syncPushToken(force: true);
    }
  }
}
