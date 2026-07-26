import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Chat data layer: remote HTTP via [NetworkCaller].
class ChatRepository {
  final NetworkCaller _network;

  ChatRepository(this._network);

  Future<Map<String, dynamic>> getConversations() async {
    final res = await _network.getRequest(url: AppUrl.conversations);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load chats');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getMessages(String conversationId) async {
    final res = await _network.getRequest(
      url: AppUrl.conversationMessages(conversationId),
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load messages');
    }
    return res.body!;
  }
}
