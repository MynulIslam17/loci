import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Chat data layer: remote HTTP via [NetworkCaller].
class ChatRepository {
  final NetworkCaller _network;

  ChatRepository(this._network);

  /// Page-based pagination: `GET /conversations?page=&limit=` (meta carries
  /// `hasNextPage`).
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.conversations,
      queryParams: {'page': '$page', 'limit': '$limit'},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load chats');
    }
    return res.body!;
  }

  /// `POST /messages/delivered` — tells the server this device received its
  /// queued messages (app launch / push handler). Idempotent and cheap;
  /// without it senders don't get their second tick while the app is closed.
  Future<void> notifyDelivered() async {
    final res = await _network.postRequest(
      url: AppUrl.messagesDelivered,
      body: const {},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to report delivery');
    }
  }

  /// `POST /conversations/:id/read` — marks the whole conversation read.
  Future<void> markConversationRead(String conversationId) async {
    final res = await _network.postRequest(
      url: AppUrl.conversationRead(conversationId),
      body: const {},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to mark as read');
    }
  }

  /// `DELETE /messages/:id` — unsend (delete for everyone).
  Future<void> unsendMessage(String messageId) async {
    final res = await _network.deleteRequest(url: AppUrl.editMessage(messageId));
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to unsend message');
    }
  }

  /// `DELETE /messages/:id/me` — hide the message only for this user.
  Future<void> deleteMessageForMe(String messageId) async {
    final res = await _network.deleteRequest(
      url: AppUrl.deleteMessageForMe(messageId),
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to delete message');
    }
  }

  /// `POST /messages/:id/reactions` — add or replace my reaction.
  Future<void> reactToMessage(String messageId, String emoji) async {
    final res = await _network.postRequest(
      url: AppUrl.messageReactions(messageId),
      body: {'emoji': emoji},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to react');
    }
  }

  /// `DELETE /messages/:id/reactions` — remove my reaction.
  Future<void> removeReaction(String messageId) async {
    final res = await _network.deleteRequest(
      url: AppUrl.messageReactions(messageId),
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to remove reaction');
    }
  }

  /// `POST /conversations` — idempotent: reuses the existing direct thread
  /// with [participantId] or creates a new one.
  Future<Map<String, dynamic>> createConversation(String participantId) async {
    final res = await _network.postRequest(
      url: AppUrl.conversations,
      body: {'participantId': participantId},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to start conversation');
    }
    return res.body!;
  }

  /// Cursor-paginated history. Pass [before] (a message id / cursor from the
  /// previous page's meta) to fetch older messages.
  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int limit = 30,
    String? before,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.conversationMessages(conversationId),
      queryParams: {
        'limit': '$limit',
        if (before != null && before.isNotEmpty) 'before': before,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load messages');
    }
    return res.body!;
  }

  Future<void> deleteConversation(String conversationId) async {
    final res = await _network.deleteRequest(
      url: AppUrl.conversationById(conversationId),
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to delete conversation');
    }
  }
}
