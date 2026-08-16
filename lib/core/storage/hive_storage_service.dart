import 'package:hive_flutter/hive_flutter.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';

/// Global, standard Hive storage manager powering the offline-first architecture.
///
/// Features:
/// - Pre-opened in-memory boxes for instant, synchronous frame-0 reads (0ms).
/// - Enforced buffer trimming limits (FIFO) to prevent memory and disk bloat:
///     • Max [maxMessagesPerChat] (30) messages per chat room.
///     • Max [maxConversations] (20) cached conversations.
///     • Max [maxFeedItems] (15) cached items per bottom navigation feed.
/// - Dedicated boxes for:
///   1. `chatBox`: Chat conversations and room message history.
///   2. `navDataBox`: Bottom navigation screen feeds (Home, Browse, Event, Network, Profile).
///   3. `appCacheBox`: General app key-value and user metadata cache.
/// - Complete privacy wipe on logout (`wipeOnLogout`).
class HiveStorageService {
  static const String chatBoxName = 'chat_storage_box';
  static const String navDataBoxName = 'nav_data_storage_box';
  static const String appCacheBoxName = 'app_cache_storage_box';

  /// Buffer trimming limits (Standardized to 20)
  static const int maxMessagesPerChat = 20;
  static const int maxConversations = 20;
  static const int maxFeedItems = 20;

  static const String _conversationsKey = 'cached_conversations';
  static const String _messagesPrefix = 'cached_messages_';
  static const String _knownConvIdsKey = 'known_conv_ids';
  static const String _profileKey = 'cached_user_profile';

  static HiveStorageService? _instance;

  /// Authoritative singleton accessor
  static HiveStorageService get instance {
    if (_instance != null) return _instance!;
    if (Hive.isBoxOpen(chatBoxName) &&
        Hive.isBoxOpen(navDataBoxName) &&
        Hive.isBoxOpen(appCacheBoxName)) {
      _instance = HiveStorageService(
        chatBox: Hive.box(chatBoxName),
        navDataBox: Hive.box(navDataBoxName),
        appCacheBox: Hive.box(appCacheBoxName),
      );
      return _instance!;
    }
    throw Exception('HiveStorageService has not been initialized yet');
  }

  static bool get isInitialized =>
      _instance != null ||
      (Hive.isBoxOpen(chatBoxName) &&
          Hive.isBoxOpen(navDataBoxName) &&
          Hive.isBoxOpen(appCacheBoxName));

  final Box _chatBox;
  final Box _navDataBox;
  final Box _appCacheBox;

  HiveStorageService({
    required Box chatBox,
    required Box navDataBox,
    required Box appCacheBox,
  })  : _chatBox = chatBox,
        _navDataBox = navDataBox,
        _appCacheBox = appCacheBox {
    _instance ??= this;
  }

  /// Global initialization called in [main] before runApp.
  static Future<HiveStorageService> init() async {
    await Hive.initFlutter();

    final chatBox = await Hive.openBox(chatBoxName);
    final navDataBox = await Hive.openBox(navDataBoxName);
    final appCacheBox = await Hive.openBox(appCacheBoxName);

    final service = HiveStorageService(
      chatBox: chatBox,
      navDataBox: navDataBox,
      appCacheBox: appCacheBox,
    );
    _instance = service;
    return service;
  }

  /// Recursively casts any dynamic Maps from Hive to `Map<String, dynamic>`.
  static dynamic _deepCast(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _deepCast(v)));
    } else if (value is List) {
      return value.map((e) => _deepCast(e)).toList();
    }
    return value;
  }

  static Map<String, dynamic> deepCastMap(Map raw) {
    return (_deepCast(raw) as Map).cast<String, dynamic>();
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 1. CHAT CACHE (Offline-First, Frame-0 Synchronous Loading with 30/20 Limit)
  // ═════════════════════════════════════════════════════════════════════════════

  /// Synchronously loads cached conversation list on frame 0.
  List<ConversationModel> getCachedConversations() {
    try {
      final raw = _chatBox.get(_conversationsKey);
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) =>
                ConversationModel.fromJson(deepCastMap(e)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Persists conversation list to Hive box, automatically trimmed to [maxConversations].
  void saveConversations(List<ConversationModel> conversations) {
    try {
      final trimmed = conversations.length > maxConversations
          ? conversations.sublist(0, maxConversations)
          : conversations;
      final list = trimmed.map((c) => c.toJson()).toList();
      _chatBox.put(_conversationsKey, list);

      final ids = _getKnownConversationIds();
      for (final c in trimmed) {
        if (c.id.isNotEmpty) ids.add(c.id);
      }
      _saveKnownConversationIds(ids);
    } catch (_) {}
  }

  /// Optimistic outbox rows live in [getPendingMessages], not room history.
  static bool isOptimistic(ChatMessageModel m) =>
      m.id.startsWith('temp_') || m.status == 'sending';

  /// Synchronously loads cached messages for [conversationId] on frame 0.
  List<ChatMessageModel> getCachedMessages(String conversationId) {
    if (conversationId.isEmpty) return [];
    try {
      final raw = _chatBox.get('$_messagesPrefix$conversationId');
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) =>
                ChatMessageModel.fromJson(deepCastMap(e)))
            .where((m) => !isOptimistic(m))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Persists room messages to Hive box, trimmed to the latest [maxMessagesPerChat].
  void saveMessages(String conversationId, List<ChatMessageModel> messages) {
    if (conversationId.isEmpty) return;
    try {
      final confirmed = messages.where((m) => !isOptimistic(m)).toList();
      final trimmed = confirmed.length > maxMessagesPerChat
          ? confirmed.sublist(confirmed.length - maxMessagesPerChat)
          : confirmed;
      final list = trimmed.map((m) => m.toJson()).toList();
      _chatBox.put('$_messagesPrefix$conversationId', list);

      final ids = _getKnownConversationIds();
      ids.add(conversationId);
      _saveKnownConversationIds(ids);
    } catch (_) {}
  }

  /// Upserts a single message into the local cache for [conversationId],
  /// replacing any matching temporary placeholder by tempId to prevent duplicates.
  void appendOrUpdateMessage(
    String conversationId,
    ChatMessageModel message, {
    String? tempId,
  }) {
    if (conversationId.isEmpty) return;
    try {
      final cached = getCachedMessages(conversationId);
      var idx = cached.indexWhere(
        (m) => m.id == message.id && m.id.isNotEmpty,
      );

      if (idx == -1 && tempId != null && tempId.isNotEmpty) {
        idx = cached.indexWhere((m) => m.id == tempId);
      }

      if (idx != -1) {
        cached[idx] = message;
      } else if (!isOptimistic(message)) {
        cached.add(message);
      }
      saveMessages(conversationId, cached);
    } catch (_) {}
  }

  /// Removes cached messages and conversation entry for [conversationId].
  void deleteConversation(String conversationId) {
    if (conversationId.isEmpty) return;
    try {
      _chatBox.delete('$_messagesPrefix$conversationId');
      _chatBox.delete('$_pendingOutboxPrefix$conversationId');

      final convs = getCachedConversations();
      convs.removeWhere((c) => c.id == conversationId);
      saveConversations(convs);

      final ids = _getKnownConversationIds();
      ids.remove(conversationId);
      _saveKnownConversationIds(ids);
    } catch (_) {}
  }

  // ── Persistent Pending Outbox Queue (Offline Sending) ─────────────────────
  static const String _pendingOutboxPrefix = 'pending_outbox_';
  static const String _pendingConvIdsKey = 'pending_outbox_conv_ids';

  Set<String> _getKnownPendingConversationIds() {
    try {
      final raw = _chatBox.get(_pendingConvIdsKey);
      if (raw is List) {
        return raw.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
    return <String>{};
  }

  void _saveKnownPendingConversationIds(Set<String> ids) {
    try {
      _chatBox.put(_pendingConvIdsKey, ids.toList());
    } catch (_) {}
  }

  /// Synchronously loads persistent pending/unsent messages for [conversationId].
  List<ChatMessageModel> getPendingMessages(String conversationId) {
    if (conversationId.isEmpty) return [];
    try {
      final raw = _chatBox.get('$_pendingOutboxPrefix$conversationId');
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => ChatMessageModel.fromJson(deepCastMap(e)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Returns all pending outbox messages grouped by conversation ID across the entire app.
  Map<String, List<ChatMessageModel>> getAllPendingMessages() {
    final result = <String, List<ChatMessageModel>>{};
    final convIds = _getKnownPendingConversationIds();
    for (final id in convIds) {
      final msgs = getPendingMessages(id);
      if (msgs.isNotEmpty) {
        result[id] = msgs;
      }
    }
    return result;
  }

  /// Saves or updates the pending outbox for [conversationId].
  void savePendingMessages(String conversationId, List<ChatMessageModel> pending) {
    if (conversationId.isEmpty) return;
    try {
      final ids = _getKnownPendingConversationIds();
      if (pending.isEmpty) {
        _chatBox.delete('$_pendingOutboxPrefix$conversationId');
        ids.remove(conversationId);
      } else {
        _chatBox.put(
          '$_pendingOutboxPrefix$conversationId',
          pending.map((m) => m.toJson()).toList(),
        );
        ids.add(conversationId);
      }
      _saveKnownPendingConversationIds(ids);
    } catch (_) {}
  }

  /// Adds a single message to the persistent pending outbox queue.
  void addPendingMessage(String conversationId, ChatMessageModel message) {
    if (conversationId.isEmpty) return;
    final list = getPendingMessages(conversationId);
    list.removeWhere((m) => m.id == message.id);
    list.add(message);
    savePendingMessages(conversationId, list);
  }

  /// Removes a message from the persistent pending outbox queue (after ACK received).
  void removePendingMessage(String conversationId, String tempId) {
    if (conversationId.isEmpty || tempId.isEmpty) return;
    final list = getPendingMessages(conversationId);
    list.removeWhere((m) => m.id == tempId);
    savePendingMessages(conversationId, list);
  }

  /// Drops [tempId] from every conversation outbox. Acks can arrive after the
  /// thread is closed, and the row may be keyed by recipient id or room id.
  void removePendingByTempId(String tempId) {
    if (tempId.isEmpty) return;
    for (final id in _getKnownPendingConversationIds().toList()) {
      removePendingMessage(id, tempId);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 2. BOTTOM NAVIGATION FEEDS & SCREEN DATA (Trimmed to maxFeedItems: 15)
  // ═════════════════════════════════════════════════════════════════════════════

  /// Synchronously reads a cached list of JSON maps for a bottom nav feed
  /// (e.g. Home questions feed, Browse businesses, Events/Routes, Network connections).
  List<Map<String, dynamic>> getFeedList(String feedKey) {
    try {
      final raw = _navDataBox.get(feedKey);
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => deepCastMap(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Saves a feed list for offline-first rendering, automatically trimmed to [maxFeedItems].
  void saveFeedList(String feedKey, List<Map<String, dynamic>> items) {
    try {
      final trimmed = items.length > maxFeedItems
          ? items.sublist(0, maxFeedItems)
          : items;
      _navDataBox.put(feedKey, trimmed);
    } catch (_) {}
  }

  /// Synchronously reads raw or serialized screen data (e.g. tab configuration, filter state).
  Map<String, dynamic>? getScreenData(String screenKey) {
    try {
      final val = _navDataBox.get(screenKey);
      if (val is Map) {
        return deepCastMap(val);
      }
    } catch (_) {}
    return null;
  }

  /// Saves screen data object or configuration map.
  void saveScreenData(String screenKey, Map<String, dynamic> data) {
    try {
      _navDataBox.put(screenKey, data);
    } catch (_) {}
  }

  /// Deletes a specific feed or screen data cache by key.
  void deleteScreenData(String screenKey) {
    try {
      _navDataBox.delete(screenKey);
    } catch (_) {}
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 3. USER PROFILE & APP CACHE
  // ═════════════════════════════════════════════════════════════════════════════

  /// Reads cached user profile JSON snapshot.
  Map<String, dynamic>? getProfile() {
    try {
      final val = _appCacheBox.get(_profileKey);
      if (val is Map) return deepCastMap(val);
    } catch (_) {}
    return null;
  }

  /// Saves user profile JSON snapshot.
  void saveProfile(Map<String, dynamic> profileJson) {
    try {
      _appCacheBox.put(_profileKey, profileJson);
    } catch (_) {}
  }

  T? get<T>(String key) {
    try {
      final val = _appCacheBox.get(key);
      if (val is T) return val;
    } catch (_) {}
    return null;
  }

  void put(String key, dynamic value) {
    try {
      _appCacheBox.put(key, value);
    } catch (_) {}
  }

  void delete(String key) {
    try {
      _appCacheBox.delete(key);
    } catch (_) {}
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 4. PRIVACY & LOGOUT WIPE (Atomically clears all Hive boxes)
  // ═════════════════════════════════════════════════════════════════════════════

  /// Completely wipes all chat messages, conversations, navigation feeds, and cache.
  Future<void> wipeOnLogout() async {
    try {
      await _chatBox.clear();
      await _navDataBox.clear();
      await _appCacheBox.clear();
    } catch (_) {}
  }

  // ── Internal Helpers ─────────────────────────────────────────────────────

  Set<String> _getKnownConversationIds() {
    try {
      final raw = _chatBox.get(_knownConvIdsKey);
      if (raw is List) {
        return raw.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
    return <String>{};
  }

  void _saveKnownConversationIds(Set<String> ids) {
    try {
      _chatBox.put(_knownConvIdsKey, ids.toList());
    } catch (_) {}
  }
}
