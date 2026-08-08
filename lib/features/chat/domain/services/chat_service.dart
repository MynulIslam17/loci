import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/chat/data/repositories/chat_repository.dart';

/// Domain orchestration for chat. Controllers call this — never NetworkCaller.
class ChatService {
  final ChatRepository _repository;

  ChatService(this._repository);

  /// One page of the conversation list (`meta.hasNextPage` drives paging).
  Future<ConversationsPage> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final body = await _repository.getConversations(page: page, limit: limit);
    final list = (body['data'] as List<dynamic>?) ?? [];
    final conversations = list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = body['meta'];
    final hasNextPage = meta is Map
        ? meta['hasNextPage'] == true
        : conversations.length >= limit;

    return ConversationsPage(
      conversations: conversations,
      page: page,
      hasNextPage: hasNextPage,
    );
  }

  Future<void> markConversationRead(String conversationId) =>
      _repository.markConversationRead(conversationId);

  Future<void> notifyDelivered() => _repository.notifyDelivered();

  Future<void> unsendMessage(String messageId) =>
      _repository.unsendMessage(messageId);

  Future<void> deleteMessageForMe(String messageId) =>
      _repository.deleteMessageForMe(messageId);

  Future<void> reactToMessage(String messageId, String emoji) =>
      _repository.reactToMessage(messageId, emoji);

  Future<void> removeReaction(String messageId) =>
      _repository.removeReaction(messageId);

  /// Starts (or reuses) the direct conversation with [participantId].
  Future<ConversationModel> createConversation(String participantId) async {
    final body = await _repository.createConversation(participantId);
    return ConversationModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// One page of history, oldest → newest. [ChatMessagesPage.nextCursor] is
  /// null when the full history has been loaded.
  Future<ChatMessagesPage> getMessages(
    String conversationId, {
    int limit = 30,
    String? before,
  }) async {
    final body = await _repository.getMessages(
      conversationId,
      limit: limit,
      before: before,
    );
    final list = (body['data'] as List<dynamic>?) ?? [];
    final messages = list
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = body['meta'];
    String? nextCursor;
    if (meta is Map) {
      // Authoritative: nextCursor is null when hasMore is false.
      nextCursor = meta['nextCursor']?.toString();
    } else if (messages.length >= limit && messages.isNotEmpty) {
      // Fallback only when the API omits meta: assume more while pages are
      // full, cursoring on the oldest message of this page.
      nextCursor = messages.first.id;
    }

    return ChatMessagesPage(messages: messages, nextCursor: nextCursor);
  }

  Future<void> deleteConversation(String conversationId) =>
      _repository.deleteConversation(conversationId);
}

class ChatMessagesPage {
  final List<ChatMessageModel> messages;
  final String? nextCursor;

  ChatMessagesPage({required this.messages, required this.nextCursor});

  bool get hasMore => nextCursor != null;
}

class ConversationsPage {
  final List<ConversationModel> conversations;
  final int page;
  final bool hasNextPage;

  ConversationsPage({
    required this.conversations,
    required this.page,
    required this.hasNextPage,
  });
}
