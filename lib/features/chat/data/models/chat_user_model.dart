/// A lightweight user reference as populated by the backend on conversations
/// and messages (`select 'name avatar lastSeen'`, with `_id -> id` transform).
class ChatUserModel {
  final String id;
  final String name;
  final String? avatar;
  final String? lastSeen;

  /// Presence snapshot from the conversations list (`otherParticipant.online`);
  /// null when the payload doesn't carry it.
  final bool? online;

  ChatUserModel({
    required this.id,
    required this.name,
    this.avatar,
    this.lastSeen,
    this.online,
  });

  factory ChatUserModel.fromJson(dynamic json) {
    // The backend sends either a populated object or a bare id string.
    if (json is String) {
      return ChatUserModel(id: json, name: '');
    }
    final map = (json as Map<String, dynamic>?) ?? {};
    return ChatUserModel(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      name: map['name'] ?? '',
      avatar: map['avatar'],
      lastSeen: map['lastSeen']?.toString(),
      online: map['online'] is bool ? map['online'] as bool : null,
    );
  }
}
