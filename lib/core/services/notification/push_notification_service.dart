import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:loci/core/services/notification/local_notification_service.dart';
import 'package:loci/core/services/notification/notification_payload.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/notification/data/repositories/push_token_repository.dart';
import 'package:loci/features/notification/presentation/utils/notification_navigation.dart';
import 'package:loci/routes/app_routes.dart';

/// Top-level background message handler required by FirebaseMessaging.
///
/// Runs in a dedicated isolate that shares no state with the app: it starts
/// with no plugin registrations, no GetX graph, and no error reporting. Any
/// exception thrown here disappears without a trace, so everything is logged
/// and guarded explicitly.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Without this the isolate has no plugin bindings and the first call into
  // flutter_local_notifications throws — invisibly, which is exactly how a
  // backgrounded push comes to show nothing at all.
  DartPluginRegistrant.ensureInitialized();

  final logger = Logger();
  logger.i(
    'FCM background message: '
    'hasNotificationBlock=${message.notification != null} data=${message.data}',
  );

  // A payload carrying a `notification` block was already posted to the tray by
  // the OS (APNs on iOS, the FCM SDK on Android), so re-posting would duplicate
  // it. Data-only payloads are displayed by nobody, and used to disappear
  // silently — those are the ones we have to render ourselves.
  if (message.notification != null) return;

  try {
    await LocalNotificationService.show(
      NotificationPayload.fromRemoteMessage(message),
    );
  } catch (e, stack) {
    logger.e('Background notification failed', error: e, stackTrace: stack);
  }
}

/// Manages FCM push notification permissions, multi-device token registration,
/// live token refresh, and notification tap routing.
///
/// The app never touches the iOS badge count — the server owns it via
/// `apns.payload.aps.badge` and it clears as the user reads notifications.
class PushNotificationService extends GetxService {
  final PushTokenRepository _repository;
  final Logger _logger = Logger();

  /// Resolved lazily: touching `FirebaseMessaging.instance` throws when
  /// `Firebase.initializeApp()` did not succeed, and constructing this service
  /// must never take the rest of the dependency graph down with it. Every call
  /// site below already runs inside a try/catch.
  FirebaseMessaging? _messagingRef;
  FirebaseMessaging get _messaging =>
      _messagingRef ??= FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  String? _lastSyncedToken;
  bool _syncing = false;

  /// APNs assigns the device token asynchronously after permission is granted;
  /// `getToken()` yields null until it lands.
  static const _apnsPollInterval = Duration(milliseconds: 500);
  static const _apnsMaxAttempts = 20;

  /// A cold-start tap must outlast the splash screen's `offAllNamed` redirect.
  static const _navigationPollInterval = Duration(milliseconds: 250);
  static const _navigationMaxAttempts = 40;

  PushNotificationService(this._repository);

  @override
  void onInit() {
    super.onInit();
    init();
  }

  /// Initializes notification permissions, tap routing, and the token listener.
  ///
  /// Each step is isolated. Previously a single `try` wrapped everything, so a
  /// throw in permissions or plugin setup silently skipped handler attachment —
  /// indistinguishable, from the outside, from pushes having stopped arriving.
  Future<void> init() async {
    await _step('local notifications', () async {
      await LocalNotificationService.init(onTap: _handleLocalTap);
    });

    await _step('message handlers', () async {
      _attachMessageHandlers();
    });

    await _step('permissions', () async {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Let iOS present pushes while the app is foregrounded. `badge: true` only
      // applies the server-sent count; it does not set one locally. This is a
      // no-op on Android, where we post the notification ourselves.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    });

    await _step('token refresh listener', () async {
      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
        syncPushToken(customToken: newToken, force: true);
      });
    });

    await _step('token sync', syncPushToken);
  }

  Future<void> _step(String name, Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stack) {
      _logger.w('Push setup step "$name" failed', error: e, stackTrace: stack);
    }
  }

  /// Retrieves the device's FCM token and sends it to `PATCH /users/me/push-token`.
  /// Must be called after every login, signup, session reload, and onTokenRefresh.
  Future<void> syncPushToken({String? customToken, bool force = false}) async {
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    if (auth == null || !auth.isLoggedIn) return;
    if (_syncing) return;

    _syncing = true;
    try {
      final token = customToken ?? await _resolveToken();
      if (token == null || token.trim().isEmpty) return;

      // Avoid redundant calls if the token has not changed unless forced (e.g. new user login)
      if (!force && token == _lastSyncedToken) return;

      final success = await _repository.updatePushToken(token);
      if (success) {
        _lastSyncedToken = token;
      }
    } catch (_) {
      // Non-fatal exception during token push sync
    } finally {
      _syncing = false;
    }
  }

  /// Resets the last synced token cache when logging out so the next user
  /// on this same device will always force-sync their session to this token.
  void clearTokenCache() {
    _lastSyncedToken = null;
  }

  // ── Token resolution ────────────────────────────────────────────────────────

  Future<String?> _resolveToken() async {
    if (Platform.isIOS && !await _awaitApnsToken()) return null;
    return _messaging.getToken();
  }

  /// Polls for the APNs device token. Without it `getToken()` returns null on
  /// iOS and the device would silently never register.
  Future<bool> _awaitApnsToken() async {
    for (var attempt = 0; attempt < _apnsMaxAttempts; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) return true;
      await Future.delayed(_apnsPollInterval);
    }
    return false;
  }

  // ── Tap + foreground routing ────────────────────────────────────────────────

  void _attachMessageHandlers() {
    _openedAppSub?.cancel();
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForeground);

    // App launched from a terminated state by tapping a notification. An FCM
    // tray notification surfaces here; one we posted ourselves comes back as a
    // launch payload instead. The two are mutually exclusive per message.
    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleTap(message);
    });
    LocalNotificationService.launchPayload().then((payload) {
      if (payload != null) _routePayload(payload);
    });
  }

  Future<void> _handleTap(RemoteMessage message) async {
    await _route(NotificationPayload.fromRemoteMessage(message));
  }

  /// A tap on a notification this app posted itself (see
  /// [LocalNotificationService]); the payload is the encoded FCM data map.
  void _handleLocalTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) _routePayload(payload);
  }

  Future<void> _routePayload(String encoded) async {
    final Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return;
      data = Map<String, dynamic>.from(decoded);
    } catch (_) {
      return;
    }
    await _route(NotificationPayload(data));
  }

  Future<void> _route(NotificationPayload payload) async {
    if (!await _awaitNavigable()) return;
    NotificationNavigation.openFromPayload(payload);
  }

  /// Android posts nothing for a push that arrives while the app is open, so
  /// render it ourselves. iOS already shows its native banner via
  /// [FirebaseMessaging.setForegroundNotificationPresentationOptions].
  void _handleForeground(RemoteMessage message) {
    _logger.i(
      'FCM foreground message received: '
      'hasNotificationBlock=${message.notification != null} '
      'route=${Get.currentRoute} data=${message.data}',
    );

    if (!Platform.isAndroid) return;

    final payload = NotificationPayload.fromRemoteMessage(message);

    // The thread on screen renders its own messages over the socket.
    if (NotificationNavigation.isConversationOnScreen(payload)) {
      _logger.i('Suppressed: that conversation is already open.');
      return;
    }

    LocalNotificationService.show(payload);
  }

  /// Waits until the session is restored and the splash redirect has settled,
  /// otherwise the pushed route is wiped by the splash's `offAllNamed`.
  Future<bool> _awaitNavigable() async {
    for (var attempt = 0; attempt < _navigationMaxAttempts; attempt++) {
      final auth = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : null;
      final route = Get.currentRoute;
      if (auth != null &&
          auth.isLoggedIn &&
          route.isNotEmpty &&
          route != AppRoutes.splash) {
        return true;
      }
      await Future.delayed(_navigationPollInterval);
    }
    return false;
  }

  @override
  void onClose() {
    _tokenRefreshSub?.cancel();
    _openedAppSub?.cancel();
    _foregroundSub?.cancel();
    super.onClose();
  }
}
