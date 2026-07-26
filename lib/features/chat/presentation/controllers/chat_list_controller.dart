import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/services/chat_socket_service.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';

/// Backs the chat list screen: loads the caller's conversations over REST and
/// keeps them live via the shared socket (new messages bump a chat to the top
/// and update its unread badge; presence toggles the online dot).
class ChatListController extends GetxController {
  ChatListController(this._service);

  final ChatService _service;
  final ChatSocketService _socket = Get.find<ChatSocketService>();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final conversations = <ConversationModel>[].obs;

  /// userIds currently online (driven by presence events).
  final onlineUserIds = <String>{}.obs;

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
    isLoading.value = true;
    errorMessage.value = null;
    try {
      conversations.assignAll(await _service.getConversations());
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      isLoading.value = false;
    }
  }

  bool isOnline(String userId) => onlineUserIds.contains(userId);

  void _onIncomingMessage(dynamic message) {
    final msg = message;
    final idx = conversations.indexWhere((c) => c.id == msg.conversationId);

    if (idx == -1) {
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
      unreadCount: fromMe ? existing.unreadCount : existing.unreadCount + 1,
    );

    conversations.removeAt(idx);
    conversations.insert(0, updated);
  }

  void _onRead(MessagesRead e) {
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
  }

  void _onPresence(PresenceEvent e) {
    if (e.isOnline) {
      onlineUserIds.add(e.userId);
    } else {
      onlineUserIds.remove(e.userId);
    }
  }

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
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }
}
