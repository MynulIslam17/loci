import 'dart:convert';

import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:loci/features/push_notification/data/models/notification_payload.dart';

/// Posts real system-tray notifications on Android and iOS.
///
/// Three cases would otherwise look like a lost notification: Android never
/// displays an incoming push itself while the app is foregrounded, it displays
/// nothing at all for data-only payloads in the background, and the backend
/// sends no push whatsoever for a chat message when the recipient's socket is
/// connected.
///
/// iOS is included because leaving it to APNs loses messages: a foregrounded
/// chat message arriving over the socket is displayed by nobody. Pushes are
/// still left to the OS on iOS — it renders them natively in the foreground
/// and the background alike — so only the socket path posts here. [_claim]
/// guards the overlap where a message reaches this class twice.
///
/// Everything here is static because the background isolate runs its own copy
/// of the app and cannot reach the GetX dependency graph.
class LocalNotificationService {
  LocalNotificationService._();

  /// Also referenced from AndroidManifest as
  /// `com.google.firebase.messaging.default_notification_channel_id`, so pushes
  /// that Android itself displays land on this same high-importance channel.
  static const String channelId = 'loci_high_importance';
  static const String _channelName = 'Loci notifications';
  static const String _channelDescription =
      'Messages, invitations and activity updates.';
  static const String _fallbackSender = 'New message';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final Logger _logger = Logger();

  static bool _initialised = false;

  /// Held separately from [_plugin] so that whoever initialises first — the
  /// background isolate, or a socket message racing startup — cannot leave the
  /// plugin permanently wired to a null tap handler. [init] only ever updates
  /// this; the dispatcher handed to the plugin stays constant.
  static DidReceiveNotificationResponseCallback? _onTap;

  /// Message ids already shown, so one that arrives over both the socket and
  /// FCM only surfaces once.
  static final Set<String> _shownKeys = <String>{};
  static const int _maxShownKeys = 200;

  /// Recent messages per conversation, backing the grouped notification. Only
  /// what the tray can usefully show is kept.
  static final Map<String, List<Message>> _threads = {};
  static const int _maxThreadMessages = 6;

  /// Downloaded avatars, keyed by URL. A null value records a failed fetch so
  /// it is not retried on every message. Bounded — avatars are ~10-50 KB each.
  static final Map<String, Uint8List?> _avatarCache = {};
  static const int _maxCachedAvatars = 30;

  /// A notification must never wait long on a slow CDN; past this the
  /// message posts without a photo, exactly like WhatsApp on a bad
  /// connection.
  static const Duration _avatarFetchTimeout = Duration(seconds: 4);

  /// Safe to call from either isolate; each one initialises its own plugin.
  ///
  /// Failure is reported rather than thrown. The background isolate has no
  /// error reporting of its own, so an exception escaping here would take the
  /// notification down with it and leave nothing behind to explain why.
  static Future<void> init({
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    if (onTap != null) _onTap = onTap;
    if (_initialised) return;

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          // Permission is requested once by PushNotificationService through
          // firebase_messaging; asking again here would raise a second prompt
          // on first launch and a denial would be remembered.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
        // Indirected through [_onTap] so a later init() can still supply the
        // handler after an early post has already initialised the plugin.
        onDidReceiveNotificationResponse: (response) => _onTap?.call(response),
      );

      // Android-only; the resolver returns null on iOS. Creating the channel up
      // front means the very first push is already high-importance (heads-up +
      // sound) instead of landing silently on Android's fallback
      // "Miscellaneous" channel.
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.high,
            ),
          );

      _initialised = true;
      debugPrint('[FCM] ✅ notification channel "$channelId" ready.');
    } catch (e, stack) {
      debugPrint('[FCM] ❌ local notification setup failed: $e');
      _logger.e(
        'Local notification setup failed; nothing can be displayed',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// The payload of the notification that cold-started the app, if any.
  static Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  /// Displays [payload] in the tray.
  ///
  /// Chat messages are merged into one notification per conversation, the way a
  /// messaging app does it: repeated messages from the same person expand into
  /// a thread rather than piling up as separate entries. Everything else posts
  /// as a standalone notification.
  static Future<void> show(NotificationPayload payload) async {
    await init();
    if (!_initialised) return;

    final title = payload.title;
    final body = payload.body;
    if (title == null && body == null) {
      _logger.w(
        'Notification had no title or body to display; nothing posted. '
        'data=${payload.data}',
      );
      return;
    }

    if (!_claim(payload.dedupeId)) {
      _logger.i('Already notified about "${payload.dedupeId}"; skipping.');
      return;
    }

    if (payload.isChatMessage && body != null) {
      await _postChatMessage(
        payload,
        body: body,
        sender: title ?? _fallbackSender,
      );
      return;
    }

    await _post(
      id: _idFrom(payload.dedupeId ?? '$title$body'),
      title: title,
      body: body,
      payload: payload,
      style: body == null
          ? null
          : BigTextStyleInformation(body, contentTitle: title),
    );
  }

  static Future<void> _postChatMessage(
    NotificationPayload payload, {
    required String body,
    required String sender,
  }) async {
    final conversationId = payload.conversationId!;

    // The sender's photo, WhatsApp-style: Android clips a MessagingStyle
    // Person icon into a circle next to their bolded name. Fetch failures
    // degrade to the name-only look rather than delaying the notification.
    final avatar = await _fetchAvatar(payload.senderAvatar);
    final person = Person(
      name: sender,
      key: payload.senderId ?? sender,
      important: true,
      icon: avatar == null ? null : ByteArrayAndroidIcon(avatar),
    );

    // Android replaces a MessagingStyle notification wholesale, so the full
    // recent history has to be re-sent on every message.
    final thread = _threads.putIfAbsent(conversationId, () => <Message>[]);
    thread.add(Message(body, DateTime.now(), person));
    if (thread.length > _maxThreadMessages) thread.removeAt(0);

    await _post(
      id: _idFrom(conversationId),
      title: sender,
      body: body,
      payload: payload,
      style: MessagingStyleInformation(
        // Represents this device's user; only outgoing messages would carry it.
        const Person(name: 'You'),
        groupConversation: false,
        messages: List<Message>.of(thread),
      ),
      isChat: true,
      largeIcon: avatar,
      messageCount: thread.length,
      ticker: '$sender: $body',
    );
  }

  /// Downloads and caches [url]. Returns null — and remembers the failure —
  /// when the fetch errors or exceeds [_avatarFetchTimeout].
  static Future<Uint8List?> _fetchAvatar(String? url) async {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (_avatarCache.containsKey(trimmed)) return _avatarCache[trimmed];

    Uint8List? bytes;
    try {
      final response =
          await http.get(Uri.parse(trimmed)).timeout(_avatarFetchTimeout);
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        bytes = response.bodyBytes;
      }
    } catch (_) {
      // Offline, slow CDN, bad URL — the notification simply posts photo-less.
    }

    if (_avatarCache.length >= _maxCachedAvatars) {
      _avatarCache.remove(_avatarCache.keys.first);
    }
    _avatarCache[trimmed] = bytes;
    return bytes;
  }

  /// Dismisses the notifications for a conversation the user just opened, and
  /// forgets its thread so the next message starts a fresh one.
  static Future<void> clearConversation(String conversationId) async {
    // Cancel unconditionally: a notification posted from the background isolate
    // leaves no thread behind in this one, but shares the conversation's id.
    _threads.remove(conversationId);
    try {
      await _plugin.cancel(id: _idFrom(conversationId));
    } catch (e, stack) {
      _logger.w('Failed to clear notifications', error: e, stackTrace: stack);
    }
  }

  static Future<void> _post({
    required int id,
    required String? title,
    required String? body,
    required NotificationPayload payload,
    StyleInformation? style,
    bool isChat = false,
    Uint8List? largeIcon,
    int? messageCount,
    String? ticker,
  }) async {
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            _channelName,
            channelDescription: _channelDescription,
            icon: 'ic_notification',
            color: const Color(0xFF32A69A),
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: style,
            // The messaging-app treatment: chat notifications are ranked and
            // rendered as conversations, show the sender's photo on the right
            // like WhatsApp, and carry the unread count into the launcher
            // badge and the collapsed banner.
            category: isChat ? AndroidNotificationCategory.message : null,
            largeIcon: largeIcon == null
                ? null
                : ByteArrayAndroidBitmap(largeIcon),
            number: messageCount,
            ticker: ticker,
          ),
          iOS: DarwinNotificationDetails(
            // Groups a conversation's notifications into one thread, the iOS
            // counterpart of the MessagingStyle grouping used on Android.
            threadIdentifier: payload.conversationId,
            // Stated explicitly rather than left to the initialisation
            // defaults: this is what makes the banner appear while the app is
            // foregrounded, which is the only time we post one at all.
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: true,
            // The server owns the badge via `apns.payload.aps.badge`; letting a
            // locally posted notification touch it would fight that count.
            presentBadge: false,
          ),
        ),
        payload: jsonEncode(payload.data),
      );
      debugPrint('[FCM] ✅ tray notification posted: id=$id title=$title');
      _logger.i('Posted tray notification id=$id title=$title');
    } catch (e, stack) {
      debugPrint('[FCM] ❌ failed to post tray notification: $e');
      _logger.e(
        'Failed to post tray notification',
        error: e,
        stackTrace: stack,
      );
    }
  }

  static int _idFrom(String seed) => seed.hashCode & 0x7FFFFFFF;

  /// Reserves [key], returning false if it was already used. Keeps the set
  /// bounded — chat traffic is not.
  static bool _claim(String? key) {
    if (key == null) return true;
    if (!_shownKeys.add(key)) return false;
    if (_shownKeys.length > _maxShownKeys) {
      _shownKeys.remove(_shownKeys.first);
    }
    return true;
  }
}
