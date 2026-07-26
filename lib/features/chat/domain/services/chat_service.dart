import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/chat/data/repositories/chat_repository.dart';

/// Domain orchestration for chat. Controllers call this — never NetworkCaller.
class ChatService {
  final ChatRepository _repository;

  ChatService(this._repository);

  Future<List<ConversationModel>> getConversations() async {
    final body = await _repository.getConversations();
    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    final body = await _repository.getMessages(conversationId);
    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
