import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/chat_user_model.dart';

/// A direct conversation as returned by `GET /conversations` (list) and
/// `GET /conversations/:id`. Each item carries the caller's `unreadCount`.
class ConversationModel {
  final String id;
  final List<ChatParticipant> participants;

  /// Pre-resolved counterpart, as sent by the newer list payloads
  /// (`otherParticipant: {id, name, avatar, lastSeen, online}`).
  final ChatUserModel? otherParticipant;
  final ChatMessageModel? lastMessage;
  final String? lastActivityAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    this.participants = const [],
    this.otherParticipant,
    this.lastMessage,
    this.lastActivityAt,
    this.unreadCount = 0,
  });

  /// The other participant (for a direct chat) relative to [myUserId].
  ChatUserModel? other(String myUserId) {
    if (otherParticipant != null) return otherParticipant;
    for (final p in participants) {
      if (p.user.id != myUserId) return p.user;
    }
    return participants.isNotEmpty ? participants.first.user : null;
  }

  ConversationModel copyWith({
    ChatMessageModel? lastMessage,
    String? lastActivityAt,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id,
      participants: participants,
      otherParticipant: otherParticipant,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final lm = json['lastMessage'];
    return ConversationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      otherParticipant: json['otherParticipant'] is Map
          ? ChatUserModel.fromJson(json['otherParticipant'])
          : null,
      lastMessage: (lm is Map<String, dynamic>)
          ? ChatMessageModel.fromJson(lm)
          : null,
      lastActivityAt: json['lastActivityAt']?.toString(),
      unreadCount: (json['unreadCount'] ?? 0) as int,
    );
  }
}

class ChatParticipant {
  final ChatUserModel user;
  final String? lastRead;

  ChatParticipant({required this.user, this.lastRead});

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      user: ChatUserModel.fromJson(json['user']),
      lastRead: json['lastRead']?.toString(),
    );
  }
}
