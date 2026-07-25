import 'package:loci/features/chat/data/models/chat_user_model.dart';

/// A single chat message, matching `GET /conversations/:id/messages` and the
/// `chat:message_received` socket payload (`{ message }`).
class ChatMessageModel {
  final String id;
  final String conversationId;
  final ChatUserModel sender;
  final String? content;
  final List<ChatAttachment> attachments;
  final List<ChatReaction> reactions;
  final bool isEdited;
  final bool isDeleted;
  final String status; // sent | delivered | read
  final String? createdAt;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    this.content,
    this.attachments = const [],
    this.reactions = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.status = 'sent',
    this.createdAt,
  });

  bool isMine(String myUserId) => sender.id == myUserId;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      conversationId: (json['conversationId'] ?? '').toString(),
      sender: ChatUserModel.fromJson(json['sender']),
      content: json['content'],
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => ChatAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => ChatReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isEdited: json['isEdited'] == true,
      isDeleted: json['isDeleted'] == true,
      status: json['status'] ?? 'sent',
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class ChatAttachment {
  final String url;
  final String type; // image | video | file | audio
  final String? originalName;

  ChatAttachment({required this.url, required this.type, this.originalName});

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      url: json['url'] ?? '',
      type: json['type'] ?? 'file',
      originalName: json['originalName'],
    );
  }
}

class ChatReaction {
  final String userId;
  final String emoji;

  ChatReaction({required this.userId, required this.emoji});

  factory ChatReaction.fromJson(Map<String, dynamic> json) {
    return ChatReaction(
      userId: (json['user'] ?? '').toString(),
      emoji: json['emoji'] ?? '',
    );
  }
}
