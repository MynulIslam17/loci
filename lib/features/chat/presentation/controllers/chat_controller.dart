import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/chat_user_model.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';

/// Drives a single open conversation: loads history over REST, joins the socket
/// room, sends messages optimistically, and reflects realtime events (incoming
/// messages, edits, deletes, read receipts, the other user typing).
class ChatController extends GetxController {
  final ChatService _service;
  final ChatSocketService _socket = Get.find<ChatSocketService>();

  /// Existing conversation id, or null when the chat is being started fresh
  /// (in which case [recipientId] is used for the first send).
  String? conversationId;
  final String? recipientId;
  final ChatUserModel other;

  ChatController(
    this._service, {
    required this.conversationId,
    required this.recipientId,
    required this.other,
  });

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool otherIsTyping = false.obs;

  /// Message currently being edited inline in the input box, if any.
  final Rxn<ChatMessageModel> editingMessage = Rxn<ChatMessageModel>();

  /// Oldest → newest for display.
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;

  String? _nextCursor;

  String get myId => Get.find<AuthController>().userModel?.id ?? '';
  String get _myId => myId;

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
      isLoading.value = false;
    }
  }

  void _bindSocket() {
    _subs.add(_socket.onMessage.listen(_onMessage));
    _subs.add(_socket.onAck.listen(_onAck));
    _subs.add(_socket.onEdited.listen(_onEdited));
    _subs.add(_socket.onDeleted.listen(_onDeleted));
    _subs.add(_socket.onTyping.listen(_onTyping));
    _subs.add(_socket.onRead.listen(_onReadReceipt));
    _subs.add(_socket.onDelivered.listen(_onDelivered));
    _subs.add(_socket.onReaction.listen(_onReactionUpdate));
    _subs.add(_socket.onError.listen(_onSocketError));
    _subs.add(_socket.onConnectionChanged.listen(_onConnectionChanged));
  }

  /// Room membership does not survive a reconnect (guide §7): re-join the
  /// open thread and refetch its tail to close any gap from the outage.
  bool _connectionDropped = false;
  void _onConnectionChanged(bool connected) {
    if (!connected) {
      _connectionDropped = true;
      return;
    }
    if (!_connectionDropped || conversationId == null) return;
    _connectionDropped = false;
    _socket.joinConversation(conversationId!);
    loadMessages(silent: true);
    _markRead();
  }

  /// [silent] refetches without flipping the loading state — used to resync
  /// after a rejected optimistic action or a reconnect gap.
  Future<void> loadMessages({bool silent = false}) async {
    if (conversationId == null) return;
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    try {
      final page = await _service.getMessages(conversationId!);
      _nextCursor = page.nextCursor;
      hasMore.value = page.hasMore;
      messages.assignAll(page.messages);
    } catch (e) {
      if (silent) return;
      errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Prepends the next (older) page when the user scrolls to the top.
  Future<void> loadOlderMessages() async {
    if (conversationId == null) return;
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    try {
      final page = await _service.getMessages(
        conversationId!,
        before: _nextCursor,
      );
      _nextCursor = page.nextCursor;
      hasMore.value = page.hasMore;
      final known = messages.map((m) => m.id).toSet();
      messages.insertAll(
        0,
        page.messages.where((m) => !known.contains(m.id)),
      );
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
    } finally {
      isLoadingMore.value = false;
    }
  }

  void sendMessage(String text) {
    final content = text.trim();
    if (content.isEmpty) return;

    final tempId =
        'temp_${DateTime.now().millisecondsSinceEpoch}_${_tempCounter++}';

    messages.add(
      ChatMessageModel(
        id: tempId,
        conversationId: conversationId ?? '',
        sender: ChatUserModel(id: _myId, name: 'me'),
        content: content,
        status: 'sending',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

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

    if (conversationId == null && ack.message.conversationId.isNotEmpty) {
      conversationId = ack.message.conversationId;
      _socket.joinConversation(conversationId!);
      _refreshChatList();
    } else if (Get.isRegistered<ChatListController>()) {
      // The server acks my own sends instead of echoing new_message, so the
      // chat list must be bumped to the top from here.
      Get.find<ChatListController>().bumpWithMessage(ack.message);
    }

    messages[idx] = ack.message;
  }

  void _onMessage(ChatMessageModel msg) {
    if (msg.conversationId != conversationId) return;
    if (msg.sender.id == _myId) return;
    if (messages.any((m) => m.id == msg.id)) return;

    messages.add(msg);
    _markRead();
  }

  void _onEdited(ChatMessageModel msg) {
    if (msg.conversationId != conversationId) return;
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx != -1) {
      messages[idx] = msg;
    }
  }

  void _onDeleted(MessageDeleted e) {
    if (e.conversationId != conversationId) return;
    final idx = messages.indexWhere((m) => m.id == e.messageId);
    if (idx == -1) return;
    if (e.forEveryone) {
      messages[idx] = messages[idx].copyWith(
        isDeleted: true,
        clearContent: true,
      );
    } else {
      messages.removeAt(idx);
    }
  }

  /// The other participant read the conversation — flip my ticks to read.
  void _onReadReceipt(MessagesRead e) {
    if (e.conversationId != conversationId) return;
    if (e.userId == _myId) return;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (isMine(m) && m.status != 'read' && m.status != 'sending') {
        messages[i] = m.copyWith(status: 'read');
      }
    }
  }

  /// The other participant came into the room — my sent messages delivered.
  void _onDelivered(MessageDelivered e) {
    if (e.conversationId != conversationId) return;
    if (e.userId == _myId) return;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (isMine(m) && m.status == 'sent') {
        messages[i] = m.copyWith(status: 'delivered');
      }
    }
  }

  void _onReactionUpdate(ReactionUpdate e) {
    final idx = messages.indexWhere((m) => m.id == e.messageId);
    if (idx == -1) return;
    messages[idx] = messages[idx].copyWith(reactions: e.reactions);
  }

  void _onSocketError(String message) {
    // The text is already user-facing (matches what REST would return, incl.
    // the deliberately generic block/not-connected message).
    SnackbarService.error(message);
    // A rejection means an optimistic change may be stale — quietly resync
    // instead of tracking per-action rollbacks.
    loadMessages(silent: true);
  }

  // ── Message actions (windows are server-enforced; UI pre-checks) ──────────

  /// Edit own message within its 24h window.
  void editMessage(ChatMessageModel msg, String newContent) {
    final content = newContent.trim();
    if (content.isEmpty || content == msg.content) return;
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(content: content, isEdited: true);
    }
    _socket.editMessage(msg.id, content);
  }

  /// Delete for everyone (within the 15-minute unsend window). Socket event
  /// so the server broadcasts `message_deleted` to the other participant in
  /// realtime; rejections come back over `chat:error`.
  void unsendMessage(ChatMessageModel msg) {
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx == -1) return;
    messages[idx] = messages[idx].copyWith(isDeleted: true, clearContent: true);
    _socket.deleteMessage(msg.id, forEveryone: true);
  }

  /// Hide the message for this user only (realtime socket event).
  void deleteForMe(ChatMessageModel msg) {
    messages.removeWhere((m) => m.id == msg.id);
    _socket.deleteMessage(msg.id, forEveryone: false);
  }

  /// Tap the same emoji to remove the reaction, another emoji to switch.
  /// One reaction per user per message — re-reacting replaces the previous
  /// one server-side. Uses the socket so the authoritative reaction list
  /// comes back as our own `message_reaction_updated` ack and reconciles the
  /// optimistic update below.
  void toggleReaction(ChatMessageModel msg, String emoji) {
    final mine = msg.myReaction(_myId);
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx == -1) return;

    final original = messages[idx];
    final others =
        original.reactions.where((r) => r.userId != _myId).toList();
    messages[idx] = original.copyWith(
      reactions: mine == emoji
          ? others
          : [...others, ChatReaction(userId: _myId, emoji: emoji)],
    );

    if (mine == emoji) {
      _socket.unreact(msg.id);
    } else {
      _socket.react(msg.id, emoji);
    }
  }

  void _onTyping(TypingEvent e) {
    if (e.conversationId != conversationId) return;
    if (e.userId == _myId) return;
    otherIsTyping.value = e.isTyping;
  }

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

  void _markRead() {
    if (conversationId == null) return;
    // Socket event so the other participant's ticks turn blue in realtime.
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
