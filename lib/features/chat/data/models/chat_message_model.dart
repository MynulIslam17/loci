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
  final String? editedAt;

  /// Server-enforced action windows (ISO timestamps): unsend within 15 min,
  /// edit within 24h of sending. Run countdowns off these, not device clocks.
  final String? unsendableUntil;
  final String? editableUntil;

  /// Server-computed button gates (`canUnsend` / `canEdit` in payloads);
  /// null when the payload omits them (e.g. socket acks).
  final bool? canUnsendFlag;
  final bool? canEditFlag;

  /// Populated preview of the message being replied to, when present.
  final ChatReplyPreview? replyTo;

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
    this.editedAt,
    this.unsendableUntil,
    this.editableUntil,
    this.canUnsendFlag,
    this.canEditFlag,
    this.replyTo,
  });

  bool isMine(String myUserId) => sender.id == myUserId;

  /// True while the server still accepts `unsend` (delete for everyone).
  /// Server flag when provided, narrowed by the live countdown window.
  bool get canUnsend => (canUnsendFlag ?? true) && _notExpired(unsendableUntil);

  /// True while the server still accepts edits.
  bool get canEdit => (canEditFlag ?? true) && _notExpired(editableUntil);

  /// The emoji this user reacted with, or null.
  String? myReaction(String myUserId) {
    for (final r in reactions) {
      if (r.userId == myUserId) return r.emoji;
    }
    return null;
  }

  static bool _notExpired(String? iso) {
    if (iso == null) return false;
    final until = DateTime.tryParse(iso);
    if (until == null) return false;
    return DateTime.now().toUtc().isBefore(until.toUtc());
  }

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? content,
    List<ChatReaction>? reactions,
    bool? isEdited,
    bool? isDeleted,
    String? status,
    bool clearContent = false,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender,
      content: clearContent ? null : (content ?? this.content),
      attachments: attachments,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      status: status ?? this.status,
      createdAt: createdAt,
      editedAt: editedAt,
      unsendableUntil: unsendableUntil,
      editableUntil: editableUntil,
      canUnsendFlag: canUnsendFlag,
      canEditFlag: canEditFlag,
      replyTo: replyTo,
    );
  }

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
      editedAt: json['editedAt']?.toString(),
      unsendableUntil: json['unsendableUntil']?.toString(),
      editableUntil: json['editableUntil']?.toString(),
      canUnsendFlag: json['canUnsend'] is bool ? json['canUnsend'] as bool : null,
      canEditFlag: json['canEdit'] is bool ? json['canEdit'] as bool : null,
      replyTo: switch (json['replyTo']) {
        // Populated preview or a bare message id, depending on the endpoint.
        final Map m => ChatReplyPreview.fromJson(Map<String, dynamic>.from(m)),
        final String id when id.isNotEmpty => ChatReplyPreview(id: id),
        _ => null,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'sender': sender.toJson(),
      if (content != null) 'content': content,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt,
      if (editedAt != null) 'editedAt': editedAt,
      if (unsendableUntil != null) 'unsendableUntil': unsendableUntil,
      if (editableUntil != null) 'editableUntil': editableUntil,
      if (canUnsendFlag != null) 'canUnsend': canUnsendFlag,
      if (canEditFlag != null) 'canEdit': canEditFlag,
      if (replyTo != null) 'replyTo': replyTo!.toJson(),
    };
  }
}

/// Minimal quoted-message preview attached to replies.
class ChatReplyPreview {
  final String id;
  final String? content;

  ChatReplyPreview({required this.id, this.content});

  factory ChatReplyPreview.fromJson(Map<String, dynamic> json) {
    return ChatReplyPreview(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      content: json['content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (content != null) 'content': content,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
      if (originalName != null) 'originalName': originalName,
    };
  }
}

class ChatReaction {
  final String userId;
  final String emoji;

  ChatReaction({required this.userId, required this.emoji});

  factory ChatReaction.fromJson(Map<String, dynamic> json) {
    // `user` is a bare id in list/socket payloads but may arrive populated.
    final user = json['user'];
    return ChatReaction(
      userId: user is Map
          ? (user['id'] ?? user['_id'] ?? '').toString()
          : (user ?? '').toString(),
      emoji: json['emoji'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'emoji': emoji,
    };
  }
}
