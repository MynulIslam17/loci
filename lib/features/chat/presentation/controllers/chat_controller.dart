import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
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
  final HiveStorageService _storage;
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
    HiveStorageService? storage,
  }) : _storage = storage ??
            (Get.isRegistered<HiveStorageService>()
                ? Get.find<HiveStorageService>()
                : (HiveStorageService.isInitialized
                    ? HiveStorageService.instance
                    : throw Exception('HiveStorageService not registered')));

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

  bool isMine(ChatMessageModel m) {
    if (_myId.isNotEmpty && m.sender.id == _myId) return true;
    if (m.sender.id == 'me') return true;
    return false;
  }

  final Set<String> _flushingTempIds = {};

  bool _isRecent(String? t1, String? t2) {
    if (t1 == null || t2 == null) return false;
    try {
      final d1 = DateTime.parse(t1).toUtc();
      final d2 = DateTime.parse(t2).toUtc();
      return (d1.difference(d2).inSeconds).abs() < 120;
    } catch (_) {
      return false;
    }
  }

  void _deduplicateMessages() {
    final seenIds = <String>{};
    final unique = <ChatMessageModel>[];

    for (final m in messages) {
      if (m.id.isNotEmpty && !seenIds.add(m.id)) {
        continue;
      }
      // Ack already landed (maybe after we left the thread) — drop the clock bubble.
      if (HiveStorageService.isOptimistic(m) && _socket.wasAcked(m.id)) {
        continue;
      }
      unique.add(m);
    }

    if (unique.length != messages.length) {
      messages.assignAll(unique);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _bindSocket();
    final outboxKey = conversationId ?? recipientId ?? '';
    if (conversationId != null) {
      // Synchronously read local cache on frame 0 for instant UI rendering.
      final cached = _storage.getCachedMessages(conversationId!);
      _dropAckedOutbox(outboxKey);
      final pending = _storage
          .getPendingMessages(outboxKey)
          .where((p) => !_socket.wasAcked(p.id))
          .toList();

      // Merge cached messages with any in-flight pending outbox messages
      final cachedIds = cached.map((m) => m.id).toSet();
      final allInitial = [
        ...cached,
        ...pending.where((p) => !cachedIds.contains(p.id)),
      ];

      if (allInitial.isNotEmpty) {
        messages.assignAll(allInitial);
        _deduplicateMessages();
        isLoading.value = false;
      } else {
        // First-time fallback for brand new or uncached chat
        isLoading.value = true;
      }

      _socket.joinConversation(conversationId!);
      // Trigger background sync
      loadMessages(silent: allInitial.isNotEmpty);
      _markRead();
    } else {
      _dropAckedOutbox(outboxKey);
      final pending = _storage
          .getPendingMessages(outboxKey)
          .where((p) => !_socket.wasAcked(p.id))
          .toList();
      if (pending.isNotEmpty) {
        messages.assignAll(pending);
        _deduplicateMessages();
      }
      isLoading.value = false;
    }

    if (_socket.isConnected) {
      unawaited(_socket.flushGlobalOutbox());
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

  /// Room membership does not survive a reconnect: re-join the
  /// open thread, flush the outbox in order, then refetch the tail.
  bool _connectionDropped = false;
  void _onConnectionChanged(bool connected) {
    if (!connected) {
      _connectionDropped = true;
      return;
    }
    final shouldResync = _connectionDropped;
    _connectionDropped = false;
    if (conversationId != null) {
      _socket.joinConversation(conversationId!);
    }
    if (shouldResync) {
      unawaited(_resyncAfterReconnect());
    } else {
      unawaited(_socket.flushGlobalOutbox());
    }
  }

  Future<void> _resyncAfterReconnect() async {
    await _socket.flushGlobalOutbox();
    if (conversationId != null) {
      await loadMessages(silent: true);
      _markRead();
    }
  }

  void _dropAckedOutbox(String outboxKey) {
    for (final p in _storage.getPendingMessages(outboxKey)) {
      if (_socket.wasAcked(p.id)) {
        _storage.removePendingByTempId(p.id);
      }
    }
  }

  /// [silent] refetches in background without showing a loading spinner — used
  /// when cached messages are already displayed or on reconnect.
  Future<void> loadMessages({bool silent = false}) async {
    if (conversationId == null) return;

    // Fast Offline Guard: short-circuit immediately if offline
    if (ConnectivityService.isCurrentOffline) {
      isLoading.value = false;
      return;
    }

    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    try {
      final page = await _service.getMessages(conversationId!);
      _nextCursor = page.nextCursor;
      hasMore.value = page.hasMore;

      final outboxKey = conversationId ?? recipientId ?? '';
      _dropAckedOutbox(outboxKey);
      final pending = _storage
          .getPendingMessages(outboxKey)
          .where((p) => !_socket.wasAcked(p.id))
          .toList();
      final server = List<ChatMessageModel>.from(page.messages);
      final usedServer = <int>{};

      for (final p in pending) {
        var matchIdx = -1;
        for (var i = 0; i < server.length; i++) {
          if (usedServer.contains(i)) continue;
          final serverMsg = server[i];
          if (serverMsg.id == p.id) {
            matchIdx = i;
            break;
          }
          final mineOnServer =
              isMine(serverMsg) || _myId.isEmpty || serverMsg.sender.id == p.sender.id;
          if (mineOnServer &&
              serverMsg.content != null &&
              p.content != null &&
              serverMsg.content == p.content &&
              _isRecent(serverMsg.createdAt, p.createdAt)) {
            matchIdx = i;
            break;
          }
        }
        if (matchIdx != -1) {
          usedServer.add(matchIdx);
          _flushingTempIds.remove(p.id);
          _socket.unlockTempId(p.id);
          _storage.removePendingMessage(outboxKey, p.id);
        }
      }

      final stillPending = _storage.getPendingMessages(outboxKey);
      final serverIds = server.map((m) => m.id).toSet();
      final pendingIds = stillPending.map((m) => m.id).toSet();

      // Keep recently-acked bubbles the REST snapshot has not caught yet.
      final localKeep = messages.where((m) {
        if (m.id.startsWith('temp_')) return false;
        if (serverIds.contains(m.id) || pendingIds.contains(m.id)) return false;
        return isMine(m);
      }).toList();

      final merged = [
        ...server,
        ...localKeep,
        ...stillPending.where((m) => !serverIds.contains(m.id)),
      ];
      merged.sort((a, b) {
        final ta = DateTime.tryParse(a.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final tb = DateTime.tryParse(b.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return ta.compareTo(tb);
      });

      messages.assignAll(merged);
      _deduplicateMessages();
      _storage.saveMessages(conversationId!, messages.toList());
    } catch (e) {
      if (silent || messages.isNotEmpty) return;
      errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Prepends the next (older) page when the user scrolls to the top.
  Future<void> loadOlderMessages() async {
    if (conversationId == null) return;
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;

    // Fast Offline Guard: do not paginate when offline
    if (ConnectivityService.isCurrentOffline) return;

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
      _deduplicateMessages();
      _storage.saveMessages(conversationId!, messages.toList());
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

    final pending = ChatMessageModel(
      id: tempId,
      conversationId: conversationId ?? '',
      sender: ChatUserModel(
        id: _myId.isNotEmpty ? _myId : 'me',
        name: 'me',
      ),
      content: content,
      status: 'sending',
      createdAt: DateTime.now().toIso8601String(),
    );

    messages.add(pending);
    _deduplicateMessages();

    final outboxKey = conversationId ?? recipientId ?? '';
    _storage.addPendingMessage(outboxKey, pending);

    // Persist optimistic message in room history & bump the list preview
    // after the outbox write so the list can read pending.last.
    if (conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().bumpWithMessage(pending);
      }
    }

    _stopTyping();
    final canSendLive = _socket.isConnected &&
        !ConnectivityService.isCurrentOffline &&
        !_socket.isFlushing;
    if (canSendLive) {
      _flushingTempIds.add(tempId);
      _socket.sendMessage(
        conversationId: conversationId,
        recipientId: conversationId == null ? recipientId : null,
        content: content,
        tempId: tempId,
      );
    }
  }

  void _onAck(MessageAck ack) {
    if (ack.tempId != null) {
      _flushingTempIds.remove(ack.tempId);
      _socket.unlockTempId(ack.tempId);
      _storage.removePendingByTempId(ack.tempId!);
    }

    var tempIdx = ack.tempId != null
        ? messages.indexWhere((m) => m.id == ack.tempId)
        : -1;

    final existingServerIdx =
        messages.indexWhere((m) => m.id == ack.message.id);

    if (existingServerIdx != -1 && tempIdx != -1 && existingServerIdx != tempIdx) {
      // Both server message (from loadMessages) and temp message exist!
      // Remove temp bubble so only 1 copy remains.
      messages.removeAt(tempIdx);
    } else if (tempIdx != -1) {
      messages[tempIdx] = ack.message;
    } else if (existingServerIdx != -1) {
      messages[existingServerIdx] = ack.message;
    } else {
      messages.add(ack.message);
    }

    _deduplicateMessages();

    if (conversationId == null && ack.message.conversationId.isNotEmpty) {
      conversationId = ack.message.conversationId;
      _socket.joinConversation(conversationId!);
      _refreshChatList();
    } else if (Get.isRegistered<ChatListController>()) {
      // The server acks my own sends instead of echoing new_message, so the
      // chat list must be bumped to the top from here.
      Get.find<ChatListController>().bumpWithMessage(ack.message);
    }

    if (conversationId != null) {
      _storage.appendOrUpdateMessage(
        conversationId!,
        ack.message,
        tempId: ack.tempId,
      );
    }
  }

  void _onMessage(ChatMessageModel msg) {
    if (msg.conversationId != conversationId) return;
    if (isMine(msg)) return;
    if (messages.any((m) => m.id == msg.id)) return;

    messages.add(msg);
    _deduplicateMessages();
    if (conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }
    _markRead();
  }

  void _onEdited(ChatMessageModel msg) {
    if (msg.conversationId != conversationId) return;
    final idx = messages.indexWhere((m) => m.id == msg.id);
    if (idx != -1) {
      messages[idx] = msg;
      if (conversationId != null) {
        _storage.saveMessages(conversationId!, messages.toList());
      }
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
    if (conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }
  }

  /// The other participant read the conversation — flip my ticks to read.
  void _onReadReceipt(MessagesRead e) {
    if (e.conversationId != conversationId) return;
    if (e.userId == _myId) return;
    var changed = false;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (isMine(m) && m.status != 'read' && m.status != 'sending') {
        messages[i] = m.copyWith(status: 'read');
        changed = true;
      }
    }
    if (changed && conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }
  }

  /// The other participant came into the room — my sent messages delivered.
  void _onDelivered(MessageDelivered e) {
    if (e.conversationId != conversationId) return;
    if (e.userId == _myId) return;
    var changed = false;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (isMine(m) && m.status == 'sent') {
        messages[i] = m.copyWith(status: 'delivered');
        changed = true;
      }
    }
    if (changed && conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }
  }

  void _onReactionUpdate(ReactionUpdate e) {
    final idx = messages.indexWhere((m) => m.id == e.messageId);
    if (idx == -1) return;
    messages[idx] = messages[idx].copyWith(reactions: e.reactions);
    if (conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }
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
      if (conversationId != null) {
        _storage.saveMessages(conversationId!, messages.toList());
      }
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
    if (conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }
    _socket.deleteMessage(msg.id, forEveryone: true);
  }

  /// Hide the message for this user only (realtime socket event).
  void deleteForMe(ChatMessageModel msg) {
    messages.removeWhere((m) => m.id == msg.id);
    if (conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }
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
    if (conversationId != null) {
      _storage.saveMessages(conversationId!, messages.toList());
    }

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
