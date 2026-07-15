import 'dart:async';

import 'package:get/get.dart';

import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/services/chat_socket_service.dart';
import '../../../data/models/chat/conversation_model.dart';
import '../auth/auth_controller.dart';

/// Backs the chat list screen: loads the caller's conversations over REST and
/// keeps them live via the shared socket (new messages bump a chat to the top
/// and update its unread badge; presence toggles the online dot).
class ChatListController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();
  final ChatSocketService _socket = Get.find<ChatSocketService>();

  bool isLoading = false;
  String? errorMessage;
  List<ConversationModel> conversations = [];

  /// userIds currently online (driven by presence events).
  final Set<String> onlineUserIds = {};

  String get _myId => Get.find<AuthController>().userModel?.id ?? '';

  final List<StreamSubscription> _subs = [];

  @override
  void onInit() {
    super.onInit();
    _bindSocket();
    fetchConversations();
  }

  void _bindSocket() {
    _subs.add(_socket.onMessage.listen(_onIncomingMessage));
    _subs.add(_socket.onRead.listen(_onRead));
    _subs.add(_socket.onPresence.listen(_onPresence));
  }

  Future<void> fetchConversations() async {
    isLoading = true;
    errorMessage = null;
    update();
    try {
      final res = await _network.getRequest(url: AppUrl.conversations);
      if (res.isSuccess && res.body != null) {
        final list = (res.body!['data'] as List<dynamic>?) ?? [];
        conversations = list
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        errorMessage = res.errorMessage ?? 'Failed to load chats';
      }
    } catch (e) {
      errorMessage = 'Failed to load chats';
    } finally {
      isLoading = false;
      update();
    }
  }

  bool isOnline(String userId) => onlineUserIds.contains(userId);

  // ── Socket reactions ───────────────────────────────────────────────────────
  void _onIncomingMessage(dynamic message) {
    final msg = message; // ChatMessageModel
    final idx = conversations.indexWhere((c) => c.id == msg.conversationId);

    if (idx == -1) {
      // A conversation we don't have yet (e.g. someone just messaged us) —
      // pull the fresh list so it appears with correct metadata.
      fetchConversations();
      return;
    }

    final existing = conversations[idx];
    final fromMe = msg.sender.id == _myId;
    final updated = ConversationModel(
      id: existing.id,
      participants: existing.participants,
      lastMessage: msg,
      lastActivityAt: msg.createdAt ?? existing.lastActivityAt,
      // Bump unread only for messages sent by the other person.
      unreadCount: fromMe ? existing.unreadCount : existing.unreadCount + 1,
    );

    conversations.removeAt(idx);
    conversations.insert(0, updated); // move to top
    update();
  }

  void _onRead(MessagesRead e) {
    // The caller read a conversation → clear its badge locally.
    if (e.userId != _myId) return;
    final idx = conversations.indexWhere((c) => c.id == e.conversationId);
    if (idx == -1) return;
    final c = conversations[idx];
    conversations[idx] = ConversationModel(
      id: c.id,
      participants: c.participants,
      lastMessage: c.lastMessage,
      lastActivityAt: c.lastActivityAt,
      unreadCount: 0,
    );
    update();
  }

  void _onPresence(PresenceEvent e) {
    if (e.isOnline) {
      onlineUserIds.add(e.userId);
    } else {
      onlineUserIds.remove(e.userId);
    }
    update();
  }

  /// Clears a conversation's unread badge locally (called when it's opened).
  void clearUnread(String conversationId) {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    final c = conversations[idx];
    if (c.unreadCount == 0) return;
    conversations[idx] = ConversationModel(
      id: c.id,
      participants: c.participants,
      lastMessage: c.lastMessage,
      lastActivityAt: c.lastActivityAt,
      unreadCount: 0,
    );
    update();
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }
}
