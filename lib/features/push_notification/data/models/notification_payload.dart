import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loci/core/enums/notification_type.dart';

/// A typed view over a notification's `data` map.
///
/// The same shape reaches the app from three directions — an FCM push, a stored
/// notification from the API, and one the app builds itself for a chat message
/// that arrived over the socket — and all three have to agree on key names.
/// Declaring them once here is what keeps them in sync; they were previously
/// spread across the display, routing and bridging code, where a single
/// mismatch silently broke deep links.
///
/// Values are read as strings because FCM flattens `data` to strings in
/// transit. Lookups accept aliases: the backend's naming varies by
/// notification type.
class NotificationPayload {
  const NotificationPayload(this.data, {this.transportId});

  /// The raw map. Re-encoded into the tray notification so a tap that arrives
  /// minutes later — possibly in a fresh process — can still be routed.
  final Map<String, dynamic> data;

  /// FCM's own message id. A last-resort de-duplication key for payloads that
  /// carry no application-level id.
  final String? transportId;

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    final notification = message.notification;
    if (notification != null) {
      // Reachable through the same accessors as a data-only payload.
      data.putIfAbsent(_titleKey, () => notification.title);
      data.putIfAbsent(_bodyKey, () => notification.body);
    }
    return NotificationPayload(data, transportId: message.messageId);
  }

  /// The payload for a chat message the app notifies about itself, having
  /// received it over the socket rather than as a push.
  factory NotificationPayload.chatMessage({
    required String conversationId,
    required String messageId,
    required String senderId,
    required String senderName,
    required String body,
    String? senderAvatar,
  }) => NotificationPayload({
    'type': NotificationType.newMessage.value,
    'conversationId': conversationId,
    'messageId': messageId,
    'senderId': senderId,
    'senderName': senderName,
    'title': senderName,
    'body': body,
    if (senderAvatar != null && senderAvatar.trim().isNotEmpty)
      'senderAvatar': senderAvatar,
  });

  // ── Keys ────────────────────────────────────────────────────────────────────

  static const _titleKey = 'title';
  static const _bodyKey = 'body';

  /// Deliberately excludes `entityId`: for a non-chat notification that key
  /// holds an event or raffle id, and treating it as a conversation would file
  /// the notification under the wrong thread. [NotificationNavigation] falls
  /// back to it only once the type is known to be a chat message.
  static const _conversationIdKeys = ['conversationId', 'conversation', 'chatId'];
  static const _messageIdKeys = ['messageId', 'chatMessageId'];
  static const _senderIdKeys = ['senderId', 'otherId', 'userId', 'fromId'];
  static const _senderNameKeys = ['senderName', 'otherName', 'senderFullName'];
  static const _senderAvatarKeys = ['senderAvatar', 'otherAvatar', 'avatar'];

  // ── Accessors ───────────────────────────────────────────────────────────────

  NotificationType get type => NotificationType.fromString(_string('type'));

  String? get title => _first(const [_titleKey]);
  String? get body => _first(const [_bodyKey, 'message']);

  String? get conversationId => _first(_conversationIdKeys);
  String? get messageId => _first(_messageIdKeys);
  String? get senderId => _first(_senderIdKeys);
  String? get senderName => _first(_senderNameKeys);
  String? get senderAvatar => _first(_senderAvatarKeys);
  String? get entityId => _first(const ['entityId']);

  /// Whether this should render as a chat message — grouped into a single
  /// notification per conversation instead of standing on its own.
  bool get isChatMessage => conversationId != null;

  /// Identifies the underlying message so the socket and push paths, which can
  /// both deliver it, only produce one notification.
  ///
  /// `entityId` is not used: two notifications about the same event are
  /// distinct, and collapsing them would drop the second.
  String? get dedupeId => messageId ?? transportId;

  String? _first(List<String> keys) {
    for (final key in keys) {
      final value = _string(key);
      if (value != null) return value;
    }
    return null;
  }

  String? _string(String key) {
    final value = data[key]?.toString().trim();
    return (value == null || value.isEmpty) ? null : value;
  }
}
