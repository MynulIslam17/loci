import 'dart:async';

import 'package:get/get.dart';

import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/services/chat_socket_service.dart';
import '../../../data/models/chat/chat_message_model.dart';
import '../../../data/models/chat/chat_user_model.dart';
import '../auth/auth_controller.dart';
import 'chat_list_controller.dart';

/// Drives a single open conversation: loads history over REST, joins the socket
/// room, sends messages optimistically, and reflects realtime events (incoming
/// messages, edits, deletes, read receipts, the other user typing).
class ChatController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();
  final ChatSocketService _socket = Get.find<ChatSocketService>();

  /// Existing conversation id, or null when the chat is being started fresh
  /// (in which case [recipientId] is used for the first send).
  String? conversationId;
  final String? recipientId;
  final ChatUserModel other;

  ChatController({
    required this.conversationId,
    required this.recipientId,
    required this.other,
  });

  bool isLoading = false;
  String? errorMessage;
  bool otherIsTyping = false;

  /// Oldest → newest for display.
  final List<ChatMessageModel> messages = [];

  String get _myId => Get.find<AuthController>().userModel?.id ?? '';

  final List<StreamSubscription> _subs = [];
  Timer? _typingDebounce;
  bool _typingSent = false;
  int _tempCounter = 0;

  bool isMine(ChatMessageModel m) => m.sender.id == _myId;

  @override
  void onInit() {
    super.onInit();
    _bindSocket();
    if (conversationId != null) {
      _socket.joinConversation(conversationId!);
      loadMessages();
      _markRead();
    } else {
      // Brand-new chat: nothing to load yet.
      isLoading = false;
    }
  }

  void _bindSocket() {
    _subs.add(_socket.onMessage.listen(_onMessage));
    _subs.add(_socket.onAck.listen(_onAck));
    _subs.add(_socket.onEdited.listen(_onEdited));
    _subs.add(_socket.onDeleted.listen(_onDeleted));
    _subs.add(_socket.onTyping.listen(_onTyping));
  }

  // ── History ────────────────────────────────────────────────────────────────
  Future<void> loadMessages() async {
    if (conversationId == null) return;
    isLoading = true;
    errorMessage = null;
    update();
    try {
      final res =
          await _network.getRequest(url: AppUrl.conversationMessages(conversationId!));
      if (res.isSuccess && res.body != null) {
        final list = (res.body!['data'] as List<dynamic>?) ?? [];
        messages
          ..clear()
          ..addAll(list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)));
      } else {
        errorMessage = res.errorMessage ?? 'Failed to load messages';
      }
    } catch (e) {
      errorMessage = 'Failed to load messages';
    } finally {
      isLoading = false;
      update();
    }
  }

  // ── Sending ──────────────────────────────────────────────────────────────────
  void sendMessage(String text) {
    final content = text.trim();
    if (content.isEmpty) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}_${_tempCounter++}';

    // Optimistic bubble so the sender sees it instantly.
    messages.add(ChatMessageModel(
      id: tempId,
      conversationId: conversationId ?? '',
      sender: ChatUserModel(id: _myId, name: 'me'),
      content: content,
      status: 'sending',
      createdAt: DateTime.now().toIso8601String(),
    ));
    update();

    _stopTyping();
    _socket.sendMessage(
      conversationId: conversationId,
      recipientId: conversationId == null ? recipientId : null,
      content: content,
      tempId: tempId,
    );
  }

  void _onAck(MessageAck ack) {
    if (ack.tempId == null) return;
    final idx = messages.indexWhere((m) => m.id == ack.tempId);
    if (idx == -1) return;

    // First message of a new conversation — adopt the server's conversationId
    // and start receiving room events for it.
    if (conversationId == null && ack.message.conversationId.isNotEmpty) {
      conversationId = ack.message.conversationId;
      _socket.joinConversation(conversationId!);
      _refreshChatList();
    }

    messages[idx] = ack.message; // replace optimistic bubble with the real one
    update();
  }

  // ── Incoming realtime events ─────────────────────────────────────────────────
  void _onMessage(ChatMessageModel msg) {
    if (msg.conversationId != conversationId) return;
    if (msg.sender.id == _myId) return; // our own echo handled via ack
    if (messages.any((m) => m.id == msg.id)) return; // dedupe

    messages.add(msg);
    update();
    _markRead(); // we're looking at the thread → mark read immediately
  }

  void _onEdited(ChatMessageModel msg) {
    if (msg.conversationId != conversationId) return;
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx != -1) {
      messages[idx] = msg;
      update();
    }
  }

  void _onDeleted(MessageDeleted e) {
    if (e.conversationId != conversationId) return;
    final idx = messages.indexWhere((m) => m.id == e.messageId);
    if (idx == -1) return;
    if (e.forEveryone) {
      final old = messages[idx];
      messages[idx] = ChatMessageModel(
        id: old.id,
        conversationId: old.conversationId,
        sender: old.sender,
        content: null,
        isDeleted: true,
        status: old.status,
        createdAt: old.createdAt,
      );
    } else {
      messages.removeAt(idx);
    }
    update();
  }

  void _onTyping(TypingEvent e) {
    if (e.conversationId != conversationId) return;
    if (e.userId == _myId) return;
    otherIsTyping = e.isTyping;
    update();
  }

  // ── Typing (debounced) ───────────────────────────────────────────────────────
  void onInputChanged(String value) {
    if (conversationId == null) return;
    if (value.trim().isEmpty) {
      _stopTyping();
      return;
    }
    if (!_typingSent) {
      _typingSent = true;
      _socket.startTyping(conversationId!);
    }
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), _stopTyping);
  }

  void _stopTyping() {
    _typingDebounce?.cancel();
    if (_typingSent && conversationId != null) {
      _typingSent = false;
      _socket.stopTyping(conversationId!);
    }
  }

  // ── Read receipts ────────────────────────────────────────────────────────────
  void _markRead() {
    if (conversationId == null) return;
    _socket.markRead(conversationId!);
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().clearUnread(conversationId!);
    }
  }

  void _refreshChatList() {
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().fetchConversations();
    }
  }

  @override
  void onClose() {
    _stopTyping();
    if (conversationId != null) _socket.leaveConversation(conversationId!);
    for (final s in _subs) {
      s.cancel();
    }
    _typingDebounce?.cancel();
    super.onClose();
  }
}
