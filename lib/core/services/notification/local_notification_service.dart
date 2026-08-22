import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:loci/core/services/notification/notification_payload.dart';

/// Posts real system-tray notifications on Android.
///
/// Three cases would otherwise look like a lost notification: Android never
/// displays an incoming push itself while the app is foregrounded, it displays
/// nothing at all for data-only payloads in the background, and the backend
/// sends no push whatsoever for a chat message when the recipient's socket is
/// connected. iOS is deliberately excluded: APNs renders the alert, sound and
/// badge natively, so a local copy there would double up and fight the
/// server-owned badge.
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

  /// Message ids already shown, so one that arrives over both the socket and
  /// FCM only surfaces once.
  static final Set<String> _shownKeys = <String>{};
  static const int _maxShownKeys = 200;

  /// Recent messages per conversation, backing the grouped notification. Only
  /// what the tray can usefully show is kept.
  static final Map<String, List<Message>> _threads = {};
  static const int _maxThreadMessages = 6;

  /// Safe to call from either isolate; each one initialises its own plugin.
  ///
  /// Failure is reported rather than thrown. The background isolate has no
  /// error reporting of its own, so an exception escaping here would take the
  /// notification down with it and leave nothing behind to explain why.
  static Future<void> init({
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    if (!Platform.isAndroid || _initialised) return;

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
        onDidReceiveNotificationResponse: onTap,
      );

      // Creating the channel up front means the very first push is already
      // high-importance (heads-up + sound) instead of landing silently on
      // Android's fallback "Miscellaneous" channel.
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
    } catch (e, stack) {
      _logger.e(
        'Local notification setup failed; nothing can be displayed',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// The payload of the notification that cold-started the app, if any.
  static Future<String?> launchPayload() async {
    if (!Platform.isAndroid) return null;
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
    if (!Platform.isAndroid) return;
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

    // Android replaces a MessagingStyle notification wholesale, so the full
    // recent history has to be re-sent on every message.
    final thread = _threads.putIfAbsent(conversationId, () => <Message>[]);
    thread.add(Message(body, DateTime.now(), Person(name: sender)));
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
    );
  }

  /// Dismisses the notifications for a conversation the user just opened, and
  /// forgets its thread so the next message starts a fresh one.
  static Future<void> clearConversation(String conversationId) async {
    if (!Platform.isAndroid) return;
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
          ),
        ),
        payload: jsonEncode(payload.data),
      );
      _logger.i('Posted tray notification id=$id title=$title');
    } catch (e, stack) {
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
