import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/chat_user_model.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';

/// Backs the chat list screen: loads the caller's conversations over REST and
/// keeps them live via the shared socket (new messages bump a chat to the top
/// and update its unread badge; presence toggles the online dot).
class ChatListController extends GetxController {
  ChatListController(this._service, [HiveStorageService? storage])
      : _storage = storage ??
            (Get.isRegistered<HiveStorageService>()
                ? Get.find<HiveStorageService>()
                : (HiveStorageService.isInitialized
                    ? HiveStorageService.instance
                    : throw Exception('HiveStorageService not registered')));

  final ChatService _service;
  final HiveStorageService _storage;
  final ChatSocketService _socket = Get.find<ChatSocketService>();
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final errorMessage = RxnString();
  final conversations = <ConversationModel>[].obs;

  /// userIds currently online (driven by presence events).
  final onlineUserIds = <String>{}.obs;

  /// Fresher lastSeen than the fetched snapshot, from `chat:user_offline`
  /// events. Presence of a key also means "explicitly went offline".
  final lastSeenOverrides = <String, String>{}.obs;

  /// conversationIds where the other participant is currently typing.
  final typingConversations = <String>{}.obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get isLoadingMore => _fetch.loadingMore.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;

  static const int _pageSize = 20;
  int _page = 1;
  final RxBool hasMore = false.obs;

  String get _myId => Get.find<AuthController>().userModel?.id ?? '';

  final List<StreamSubscription> _subs = [];

  @override
  void onInit() {
    super.onInit();
    _loadFromLocalCache();
    _bindSocket();

    if (Get.isRegistered<ConnectivityService>()) {
      _subs.add(
        Get.find<ConnectivityService>().onReconnect.listen((_) {
          fetchConversations(isRefresh: true);
        }),
      );
    }

    fetchConversations();
    // Delivery receipt (guide §6): flips queued messages to `delivered` and
    // notifies each sender — covers pushes received while the app was closed.
    _service.notifyDelivered().catchError((_) {});
  }

  /// Synchronously loads cached conversations on frame 0 to eliminate spinners,
  /// decorating any conversations with active pending outbox messages.
  void _loadFromLocalCache() {
    final cached = _storage.getCachedConversations();
    if (cached.isNotEmpty) {
      final decorated = cached.map((c) {
        final pending = _storage.getPendingMessages(c.id);
        if (pending.isNotEmpty) {
          return c.copyWith(lastMessage: pending.last);
        }
        return c;
      }).toList();

      conversations.assignAll(decorated);
      _seedPresence(cached);
      _fetch.endFirstPage(markFetched: true);
    }
  }

  void _bindSocket() {
    _subs.add(_socket.onMessage.listen(_onIncomingMessage));
    _subs.add(_socket.onAck.listen(onAckReceived));
    _subs.add(_socket.onRead.listen(_onRead));
    _subs.add(_socket.onPresence.listen(_onPresence));
    _subs.add(_socket.onTyping.listen(_onTyping));
    _subs.add(_socket.onEdited.listen(_onEdited));
    _subs.add(_socket.onDeleted.listen(_onDeleted));
    _subs.add(_socket.onDelivered.listen(_onDelivered));
  }

  void onAckReceived(MessageAck ack) {
    if (ack.tempId != null) {
      _storage.removePendingMessage(ack.message.conversationId, ack.tempId!);
    }
    _onIncomingMessage(ack.message);
  }

  Future<void> fetchConversations({bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    // Fast Offline Guard: short-circuit immediately if offline
    if (ConnectivityService.isCurrentOffline) {
      _fetch.endFirstPage(markFetched: true);
      return;
    }

    _fetch.beginFirstPage(isRefresh: isRefresh || conversations.isNotEmpty);
    errorMessage.value = null;
    try {
      final result = await _service.getConversations(
        page: 1,
        limit: _pageSize,
      );
      _page = 1;
      hasMore.value = result.hasNextPage;
      conversations.assignAll(result.conversations);
      _storage.saveConversations(result.conversations);
      _seedPresence(result.conversations);
      _fetch.endFirstPage();
    } catch (e) {
      if (conversations.isEmpty) {
        errorMessage.value = AppErrorMessages.sanitize(e);
      }
      _fetch.endFirstPage(markFetched: hasFetched || conversations.isNotEmpty);
    }
  }

  /// Appends the next page when the list is scrolled near the bottom.
  Future<void> loadMore() async {
    if (!hasMore.value || _fetch.isBusy) return;

    // Fast Offline Guard: do not paginate when offline
    if (ConnectivityService.isCurrentOffline) return;

    _fetch.beginLoadMore();
    try {
      final result = await _service.getConversations(
        page: _page + 1,
        limit: _pageSize,
      );
      _page = result.page;
      hasMore.value = result.hasNextPage;
      final known = conversations.map((c) => c.id).toSet();
      conversations.addAll(
        result.conversations.where((c) => !known.contains(c.id)),
      );
      _storage.saveConversations(conversations.toList());
      _seedPresence(result.conversations);
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
    } finally {
      _fetch.endLoadMore();
    }
  }

  /// The list payload carries an authoritative `online` snapshot per
  /// counterpart — presence events alone can't tell us who was already
  /// online before we connected.
  void _seedPresence(List<ConversationModel> items) {
    for (final c in items) {
      final user = c.otherParticipant;
      if (user == null || user.online == null) continue;
      if (user.online!) {
        onlineUserIds.add(user.id);
      } else {
        onlineUserIds.remove(user.id);
      }
    }
  }

  bool isOnline(String userId) => onlineUserIds.contains(userId);

  bool isUserActive(ChatUserModel? user) {
    if (user == null) return false;
    if (onlineUserIds.contains(user.id)) return true;
    // An explicit user_offline event is authoritative — no heuristics after it.
    if (lastSeenOverrides.containsKey(user.id)) return false;
    // Otherwise fall back to the fetched snapshot: a very recent lastSeen
    // still counts as active.
    final lastSeen = DateTime.tryParse(user.lastSeen ?? '');
    if (lastSeen == null) return false;
    return DateTime.now().toUtc().difference(lastSeen.toUtc()) <
        const Duration(minutes: 2);
  }

  /// Freshest known lastSeen for [user] — live offline events win over the
  /// snapshot fetched with the conversation list.
  String? lastSeenFor(ChatUserModel? user) {
    if (user == null) return null;
    return lastSeenOverrides[user.id] ?? user.lastSeen;
  }

  bool isTyping(String conversationId) =>
    typingConversations.contains(conversationId);

  /// Total unread messages across all conversations — drives the badge on
  /// the global app-bar chat icon. Reactive: reading it inside an Obx
  /// re-renders on every list change (incoming message, mark read, …).
  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// Moves the conversation carrying [msg] to the top with an updated
  /// preview. Used for both incoming messages and my own sent messages
  /// (via the send ack, since the server doesn't echo them as new_message).
  void bumpWithMessage(ChatMessageModel msg) => _onIncomingMessage(msg);

  void _onIncomingMessage(ChatMessageModel msg) {
    _storage.appendOrUpdateMessage(msg.conversationId, msg);

    final idx = conversations.indexWhere((c) => c.id == msg.conversationId);

    if (idx == -1) {
      fetchConversations(isRefresh: true);
      return;
    }

    final existing = conversations[idx];
    final fromMe = msg.sender.id == _myId;
    final updated = existing.copyWith(
      lastMessage: msg,
      lastActivityAt: msg.createdAt ?? existing.lastActivityAt,
      unreadCount: fromMe ? existing.unreadCount : existing.unreadCount + 1,
    );

    conversations.removeAt(idx);
    conversations.insert(0, updated);
    _storage.saveConversations(conversations.toList());
  }

  void _onRead(MessagesRead e) {
    final idx = conversations.indexWhere((c) => c.id == e.conversationId);
    if (idx == -1) return;
    final c = conversations[idx];

    if (e.userId == _myId) {
      // I read it (possibly on another device): clear the badge.
      conversations[idx] = c.copyWith(unreadCount: 0);
      _storage.saveConversations(conversations.toList());
      return;
    }

    // The other participant read my messages: blue ticks on the preview.
    final lm = c.lastMessage;
    if (lm == null || lm.sender.id != _myId || lm.status == 'read') return;
    conversations[idx] = c.copyWith(lastMessage: lm.copyWith(status: 'read'));
    _storage.saveConversations(conversations.toList());
  }

  /// The other participant became reachable: my sent preview goes ✓✓ (grey).
  void _onDelivered(MessageDelivered e) {
    if (e.userId == _myId) return;
    final idx = conversations.indexWhere((c) => c.id == e.conversationId);
    if (idx == -1) return;
    final c = conversations[idx];
    final lm = c.lastMessage;
    if (lm == null || lm.sender.id != _myId || lm.status != 'sent') return;
    conversations[idx] = c.copyWith(
      lastMessage: lm.copyWith(status: 'delivered'),
    );
    _storage.saveConversations(conversations.toList());
  }

  void _onPresence(PresenceEvent e) {
    if (e.isOnline) {
      onlineUserIds.add(e.userId);
      lastSeenOverrides.remove(e.userId);
    } else {
      onlineUserIds.remove(e.userId);
      lastSeenOverrides[e.userId] =
          e.lastSeen ?? DateTime.now().toUtc().toIso8601String();
    }
  }

  void _onTyping(TypingEvent e) {
    if (e.userId == _myId) return;
    if (e.isTyping) {
      typingConversations.add(e.conversationId);
    } else {
      typingConversations.remove(e.conversationId);
    }
  }

  /// Keeps the preview text in sync when the conversation's last message is
  /// edited. In place — editing must not reorder the list.
  void _onEdited(ChatMessageModel msg) {
    _storage.appendOrUpdateMessage(msg.conversationId, msg);

    final idx = conversations.indexWhere((c) => c.id == msg.conversationId);
    if (idx == -1) return;
    final c = conversations[idx];
    if (c.lastMessage?.id != msg.id) return;
    conversations[idx] = c.copyWith(lastMessage: msg);
    _storage.saveConversations(conversations.toList());
  }

  /// When the last message is unsent for everyone, the preview becomes the
  /// "deleted" placeholder.
  void _onDeleted(MessageDeleted e) {
    if (!e.forEveryone) return;
    final idx = conversations.indexWhere((c) => c.id == e.conversationId);
    if (idx == -1) return;
    final c = conversations[idx];
    if (c.lastMessage == null || c.lastMessage!.id != e.messageId) return;
    conversations[idx] = c.copyWith(
      lastMessage: c.lastMessage!.copyWith(isDeleted: true, clearContent: true),
    );
    _storage.saveConversations(conversations.toList());
  }

  /// Soft-deletes the conversation for this user (history is hidden until a
  /// new message revives the thread). Optimistic, with rollback on failure.
  Future<void> deleteConversation(String conversationId) async {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    final removed = conversations.removeAt(idx);
    _storage.deleteConversation(conversationId);
    try {
      await _service.deleteConversation(conversationId);
    } catch (e) {
      conversations.insert(idx.clamp(0, conversations.length), removed);
      _storage.saveConversations(conversations.toList());
      SnackbarService.error(AppErrorMessages.sanitize(e));
    }
  }

  void clearUnread(String conversationId) {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    final c = conversations[idx];
    if (c.unreadCount == 0) return;
    conversations[idx] = c.copyWith(unreadCount: 0);
    _storage.saveConversations(conversations.toList());
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }
}
