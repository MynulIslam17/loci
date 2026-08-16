import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/chat_user_model.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';
import 'package:loci/features/chat/presentation/controllers/chat_controller.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/features/home/data/models/question_list_response.dart';
import 'package:loci/features/home/data/models/question_model.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/home/presentation/controllers/question_list_controller.dart';
import 'package:loci/features/home/presentation/controllers/ad_list_controller.dart';
import 'package:loci/features/my_business/data/models/ad_item_model.dart';
import 'package:loci/shared/models/pagination_model.dart';

/// Fake mock implementation of ChatService for unit testing.
class FakeChatService implements ChatService {
  List<ConversationModel> conversationsToReturn = [];
  List<ChatMessageModel> messagesToReturn = [];
  bool getMessagesCalled = false;
  bool getConversationsCalled = false;

  @override
  Future<ConversationsPage> getConversations({int page = 1, int limit = 20}) async {
    getConversationsCalled = true;
    return ConversationsPage(
      conversations: conversationsToReturn,
      page: page,
      hasNextPage: false,
    );
  }

  @override
  Future<ChatMessagesPage> getMessages(
    String conversationId, {
    int limit = 30,
    String? before,
  }) async {
    getMessagesCalled = true;
    return ChatMessagesPage(
      messages: messagesToReturn,
      nextCursor: null,
    );
  }

  @override
  Future<ConversationModel> createConversation(String participantId) async {
    return ConversationModel(id: 'conv_created', participants: []);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {}

  @override
  Future<void> deleteMessageForMe(String messageId) async {}

  @override
  Future<void> markConversationRead(String conversationId) async {}

  @override
  Future<void> notifyDelivered() async {}

  @override
  Future<void> reactToMessage(String messageId, String emoji) async {}

  @override
  Future<void> removeReaction(String messageId) async {}

  @override
  Future<void> unsendMessage(String messageId) async {}
}

class FakeAuthService implements AuthService {
  @override
  Future<({String? role, String? token, UserModel? user})> loadSession() async {
    return (role: 'user', token: 'mock_token', user: null);
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logoutRemote() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHomeService implements HomeService {
  int getQuestionsCallCount = 0;
  int getAdsCallCount = 0;

  @override
  Future<QuestionListResponse> getQuestions({
    int page = 1,
    int limit = 20,
  }) async {
    getQuestionsCallCount++;
    return QuestionListResponse(
      data: <QuestionModel>[],
      meta: PaginationMeta(
        total: 0,
        page: page,
        limit: limit,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      ),
    );
  }

  @override
  Future<List<AdItemModel>> getAds() async {
    getAdsCallCount++;
    return <AdItemModel>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake in-memory box implementation for unit tests.
class FakeInMemoryHiveBox implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(key, {defaultValue}) =>
      _data.containsKey(key) ? _data[key] : defaultValue;

  @override
  Future<void> put(key, value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(key) async {
    _data.remove(key);
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  bool containsKey(key) => _data.containsKey(key);

  @override
  bool get isOpen => true;

  @override
  String get name => 'fake_box';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

HiveStorageService createTestHiveService() {
  return HiveStorageService(
    chatBox: FakeInMemoryHiveBox(),
    navDataBox: FakeInMemoryHiveBox(),
    appCacheBox: FakeInMemoryHiveBox(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Requirement 1 & Models: toJson and fromJson Serialization', () {
    test('ChatMessageModel round-trips through toJson and fromJson', () {
      final original = ChatMessageModel(
        id: 'msg_1',
        conversationId: 'conv_1',
        sender: ChatUserModel(id: 'u1', name: 'Alice', avatar: 'alice.png', online: true),
        content: 'Hello World',
        attachments: [
          ChatAttachment(url: 'https://img.png', type: 'image', originalName: 'pic.png'),
        ],
        reactions: [
          ChatReaction(userId: 'u2', emoji: '❤️'),
        ],
        isEdited: true,
        isDeleted: false,
        status: 'delivered',
        createdAt: '2026-08-15T10:00:00.000Z',
        editedAt: '2026-08-15T10:05:00.000Z',
        unsendableUntil: '2026-08-15T10:15:00.000Z',
        editableUntil: '2026-08-16T10:00:00.000Z',
        canUnsendFlag: true,
        canEditFlag: true,
        replyTo: ChatReplyPreview(id: 'msg_0', content: 'Earlier text'),
      );

      final json = original.toJson();
      final restored = ChatMessageModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.conversationId, original.conversationId);
      expect(restored.sender.id, original.sender.id);
      expect(restored.sender.name, original.sender.name);
      expect(restored.sender.avatar, original.sender.avatar);
      expect(restored.sender.online, original.sender.online);
      expect(restored.content, original.content);
      expect(restored.attachments.length, 1);
      expect(restored.attachments.first.url, 'https://img.png');
      expect(restored.attachments.first.type, 'image');
      expect(restored.attachments.first.originalName, 'pic.png');
      expect(restored.reactions.length, 1);
      expect(restored.reactions.first.userId, 'u2');
      expect(restored.reactions.first.emoji, '❤️');
      expect(restored.isEdited, isTrue);
      expect(restored.isDeleted, isFalse);
      expect(restored.status, 'delivered');
      expect(restored.createdAt, original.createdAt);
      expect(restored.editedAt, original.editedAt);
      expect(restored.replyTo?.id, 'msg_0');
      expect(restored.replyTo?.content, 'Earlier text');
    });

    test('ChatUserModel round-trips through toJson and fromJson', () {
      final original = ChatUserModel(
        id: 'u_99',
        name: 'John Doe',
        avatar: 'https://avatar.png',
        lastSeen: '2026-08-15T10:00:00.000Z',
        online: true,
      );
      final json = original.toJson();
      final restored = ChatUserModel.fromJson(json);

      expect(restored.id, 'u_99');
      expect(restored.name, 'John Doe');
      expect(restored.avatar, 'https://avatar.png');
      expect(restored.lastSeen, '2026-08-15T10:00:00.000Z');
      expect(restored.online, isTrue);
    });

    test('ChatReaction and ChatAttachment round-trip through toJson and fromJson', () {
      final reaction = ChatReaction(userId: 'u_1', emoji: '🎉');
      final rJson = reaction.toJson();
      final restoredR = ChatReaction.fromJson(rJson);
      expect(restoredR.userId, 'u_1');
      expect(restoredR.emoji, '🎉');

      final attachment = ChatAttachment(
        url: 'https://file.pdf',
        type: 'file',
        originalName: 'document.pdf',
      );
      final aJson = attachment.toJson();
      final restoredA = ChatAttachment.fromJson(aJson);
      expect(restoredA.url, 'https://file.pdf');
      expect(restoredA.type, 'file');
      expect(restoredA.originalName, 'document.pdf');
    });

    test('ConversationModel round-trips through toJson and fromJson', () {
      final original = ConversationModel(
        id: 'conv_100',
        participants: [
          ChatParticipant(
            user: ChatUserModel(id: 'u1', name: 'Alice'),
            lastRead: '2026-08-15T10:00:00.000Z',
          ),
          ChatParticipant(
            user: ChatUserModel(id: 'u2', name: 'Bob'),
            lastRead: '2026-08-15T09:50:00.000Z',
          ),
        ],
        otherParticipant: ChatUserModel(id: 'u2', name: 'Bob', online: true),
        lastMessage: ChatMessageModel(
          id: 'msg_last',
          conversationId: 'conv_100',
          sender: ChatUserModel(id: 'u2', name: 'Bob'),
          content: 'See you soon!',
          status: 'delivered',
        ),
        lastActivityAt: '2026-08-15T10:00:00.000Z',
        unreadCount: 3,
      );

      final json = original.toJson();
      final restored = ConversationModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.participants.length, 2);
      expect(restored.participants.first.user.name, 'Alice');
      expect(restored.otherParticipant?.id, 'u2');
      expect(restored.otherParticipant?.name, 'Bob');
      expect(restored.otherParticipant?.online, isTrue);
      expect(restored.lastMessage?.id, 'msg_last');
      expect(restored.lastMessage?.content, 'See you soon!');
      expect(restored.unreadCount, 3);
      expect(restored.lastActivityAt, '2026-08-15T10:00:00.000Z');
    });
  });

  group('HiveStorageService: Unified Chat, Bottom Navigation & Generic Caching', () {
    late HiveStorageService hiveService;

    setUp(() {
      hiveService = createTestHiveService();
    });

    test('saves and synchronously retrieves conversations via Hive', () {
      expect(hiveService.getCachedConversations(), isEmpty);

      final convs = [
        ConversationModel(
          id: 'conv_1',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob'),
          unreadCount: 1,
        ),
      ];

      hiveService.saveConversations(convs);
      final retrieved = hiveService.getCachedConversations();

      expect(retrieved.length, 1);
      expect(retrieved.first.id, 'conv_1');
      expect(retrieved.first.otherParticipant?.name, 'Bob');
      expect(retrieved.first.unreadCount, 1);
    });

    test('saves and synchronously retrieves room messages via Hive', () {
      expect(hiveService.getCachedMessages('conv_1'), isEmpty);

      final msgs = [
        ChatMessageModel(
          id: 'm1',
          conversationId: 'conv_1',
          sender: ChatUserModel(id: 'u1', name: 'Alice'),
          content: 'First cached message in Hive',
        ),
        ChatMessageModel(
          id: 'm2',
          conversationId: 'conv_1',
          sender: ChatUserModel(id: 'u2', name: 'Bob'),
          content: 'Second cached message in Hive',
        ),
      ];

      hiveService.saveMessages('conv_1', msgs);
      final retrieved = hiveService.getCachedMessages('conv_1');

      expect(retrieved.length, 2);
      expect(retrieved[0].content, 'First cached message in Hive');
      expect(retrieved[1].content, 'Second cached message in Hive');
    });

    test('Bottom Navigation Feed: auto-trims to maxFeedItems (20)', () {
      final largeFeed = List.generate(
        25,
        (i) => {'id': 'post_$i', 'title': 'Question $i'},
      );
      hiveService.saveFeedList('home_feed_cache', largeFeed);

      final cachedFeed = hiveService.getFeedList('home_feed_cache');
      expect(cachedFeed.length, HiveStorageService.maxFeedItems); // 20
      expect(cachedFeed.first['id'], 'post_0');
      expect(cachedFeed.last['id'], 'post_19');
    });

    test('Home Feed QuestionModel successfully parses nested dynamic maps from Hive', () {
      final dynamicMap = <dynamic, dynamic>{
        '_id': 'q_123',
        'content': 'What is your favorite food?',
        'author': <dynamic, dynamic>{
          '_id': 'a_1',
          'name': 'Chef John',
          'avatar': 'avatar.png',
        },
        'options': <dynamic>[
          <dynamic, dynamic>{
            'optionId': 'opt_1',
            'text': 'Pizza',
            'voteCount': 5,
            'percentage': 50,
            'voters': <dynamic>[
              <dynamic, dynamic>{'userId': 'u1', 'name': 'Sam', 'avatar': 'sam.png'}
            ],
          },
        ],
      };

      hiveService.saveFeedList('home_feed_questions', [dynamicMap.cast<String, dynamic>()]);

      final cachedFeed = hiveService.getFeedList('home_feed_questions');
      expect(cachedFeed.isNotEmpty, isTrue);

      final model = QuestionModel.fromJson(cachedFeed.first);
      expect(model.id, 'q_123');
      expect(model.author.name, 'Chef John');
      expect(model.options.first.text, 'Pizza');
      expect(model.options.first.voters.first.name, 'Sam');
    });

    test('Chat Messages: auto-trims to latest maxMessagesPerChat (20)', () {
      final largeMessages = List.generate(
        40,
        (i) => ChatMessageModel(
          id: 'msg_$i',
          conversationId: 'conv_trim',
          sender: ChatUserModel(id: 'u1', name: 'Alice'),
          content: 'Message $i',
        ),
      );

      hiveService.saveMessages('conv_trim', largeMessages);

      final cachedMsgs = hiveService.getCachedMessages('conv_trim');
      expect(cachedMsgs.length, HiveStorageService.maxMessagesPerChat); // 20
      // Latest 20 preserved (from msg_20 to msg_39)
      expect(cachedMsgs.first.id, 'msg_20');
      expect(cachedMsgs.last.id, 'msg_39');
    });

    test('Conversations List: auto-trims to maxConversations (20)', () {
      final largeConvs = List.generate(
        35,
        (i) => ConversationModel(id: 'conv_$i'),
      );

      hiveService.saveConversations(largeConvs);

      final cachedConvs = hiveService.getCachedConversations();
      expect(cachedConvs.length, HiveStorageService.maxConversations); // 20
      expect(cachedConvs.first.id, 'conv_0');
      expect(cachedConvs.last.id, 'conv_19');
    });

    test('User Profile Snapshot: saves and retrieves snapshot', () {
      final profile = {
        'id': 'user_123',
        'name': 'Azaan',
        'email': 'azaan@example.com',
        'role': 'business_owner',
      };
      hiveService.saveProfile(profile);

      final cached = hiveService.getProfile();
      expect(cached?['id'], 'user_123');
      expect(cached?['name'], 'Azaan');
      expect(cached?['role'], 'business_owner');
    });

    test('Generic App Cache: put, get, delete', () {
      hiveService.put('user_theme_pref', 'dark');
      expect(hiveService.get<String>('user_theme_pref'), 'dark');

      hiveService.delete('user_theme_pref');
      expect(hiveService.get<String>('user_theme_pref'), isNull);
    });

    test('Persistent Pending Outbox Queue: adds, reads, and removes on ACK', () {
      final msg1 = ChatMessageModel(
        id: 'temp_outbox_1',
        conversationId: 'conv_outbox',
        sender: ChatUserModel(id: 'me', name: 'Me'),
        content: 'Offline message 1',
        status: 'sending',
      );
      final msg2 = ChatMessageModel(
        id: 'temp_outbox_2',
        conversationId: 'conv_outbox',
        sender: ChatUserModel(id: 'me', name: 'Me'),
        content: 'Offline message 2',
        status: 'sending',
      );

      hiveService.addPendingMessage('conv_outbox', msg1);
      hiveService.addPendingMessage('conv_outbox', msg2);

      final pending = hiveService.getPendingMessages('conv_outbox');
      expect(pending.length, 2);
      expect(pending[0].content, 'Offline message 1');
      expect(pending[1].content, 'Offline message 2');

      // On ACK of first message
      hiveService.removePendingMessage('conv_outbox', 'temp_outbox_1');
      final remaining = hiveService.getPendingMessages('conv_outbox');
      expect(remaining.length, 1);
      expect(remaining.first.id, 'temp_outbox_2');
    });

    test('wipeOnLogout clears chat, nav data, and app cache completely', () async {
      hiveService.saveConversations([ConversationModel(id: 'conv_1')]);
      hiveService.saveMessages('conv_1', [
        ChatMessageModel(
          id: 'm1',
          conversationId: 'conv_1',
          sender: ChatUserModel(id: 'u1', name: 'Alice'),
          content: 'Secret',
        ),
      ]);
      hiveService.saveFeedList('home_feed', [{'status': 'loaded'}]);
      hiveService.saveProfile({'id': 'u1'});
      hiveService.put('app_key', 'value');

      expect(hiveService.getCachedConversations(), isNotEmpty);
      expect(hiveService.getCachedMessages('conv_1'), isNotEmpty);

      await hiveService.wipeOnLogout();

      expect(hiveService.getCachedConversations(), isEmpty);
      expect(hiveService.getCachedMessages('conv_1'), isEmpty);
      expect(hiveService.getFeedList('home_feed'), isEmpty);
      expect(hiveService.getProfile(), isNull);
      expect(hiveService.get('app_key'), isNull);
    });
  });

  group('Requirement 2, 3 & 4: Instant UI Loading, Background Sync, First-Time Fallback in ChatController', () {
    late HiveStorageService hiveService;
    late FakeChatService fakeService;

    setUp(() {
      Get.reset();
      hiveService = createTestHiveService();
      fakeService = FakeChatService();

      Get.put<HiveStorageService>(hiveService);
      Get.put<ChatSocketService>(ChatSocketService());

      final conn = ConnectivityService.instance;
      conn.isOnline.value = true;
      conn.isOffline.value = false;

      final authCtrl = AuthController(FakeAuthService());
      authCtrl.userModelRx.value = UserModel(
        id: 'my_user_id',
        name: 'Me',
        email: 'me@example.com',
        role: 'user',
        status: 'active',
        createdAt: '2026-08-15T10:00:00.000Z',
      );
      Get.put<AuthController>(authCtrl);
    });

    tearDown(() {
      Get.reset();
    });

    test('Instant UI Loading: When cache exists in Hive, loads synchronously on frame 0 with isLoading = false', () async {
      final cachedMsgs = [
        ChatMessageModel(
          id: 'msg_cached_1',
          conversationId: 'conv_123',
          sender: ChatUserModel(id: 'other_user', name: 'Partner'),
          content: 'Cached message from Hive rendered instantly',
        ),
      ];
      hiveService.saveMessages('conv_123', cachedMsgs);

      fakeService.messagesToReturn = [
        ...cachedMsgs,
        ChatMessageModel(
          id: 'msg_server_2',
          conversationId: 'conv_123',
          sender: ChatUserModel(id: 'other_user', name: 'Partner'),
          content: 'New message from background sync',
        ),
      ];

      final controller = ChatController(
        fakeService,
        conversationId: 'conv_123',
        recipientId: null,
        other: ChatUserModel(id: 'other_user', name: 'Partner'),
        storage: hiveService,
      );

      expect(controller.messages, isEmpty);

      controller.onInit();

      // SYNCHRONOUS: Frame 0 populated instantly
      expect(controller.messages.length, 1);
      expect(controller.messages.first.content, 'Cached message from Hive rendered instantly');
      expect(controller.isLoading.value, isFalse);

      // Background sync completes
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.messages.length, 2);
      expect(controller.messages[1].content, 'New message from background sync');
      expect(hiveService.getCachedMessages('conv_123').length, 2);

      controller.onClose();
    });

    test('First-Time Fallback: When cache is empty, sets isLoading = true and caches fetched messages to Hive', () async {
      expect(hiveService.getCachedMessages('conv_new'), isEmpty);

      fakeService.messagesToReturn = [
        ChatMessageModel(
          id: 'msg_net_1',
          conversationId: 'conv_new',
          sender: ChatUserModel(id: 'other_user', name: 'New Friend'),
          content: 'First time message from API into Hive',
        ),
      ];

      final controller = ChatController(
        fakeService,
        conversationId: 'conv_new',
        recipientId: null,
        other: ChatUserModel(id: 'other_user', name: 'New Friend'),
        storage: hiveService,
      );

      controller.onInit();

      expect(controller.isLoading.value, isTrue);
      expect(controller.messages, isEmpty);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.isLoading.value, isFalse);
      expect(controller.messages.length, 1);
      expect(controller.messages.first.content, 'First time message from API into Hive');

      final savedInHive = hiveService.getCachedMessages('conv_new');
      expect(savedInHive.length, 1);
      expect(savedInHive.first.content, 'First time message from API into Hive');

      controller.onClose();
    });

    test('sendMessage optimistically adds message and persists to Hive', () {
      final controller = ChatController(
        fakeService,
        conversationId: 'conv_send',
        recipientId: null,
        other: ChatUserModel(id: 'u2', name: 'Bob'),
        storage: hiveService,
      );
      controller.onInit();

      controller.sendMessage('Hello Hive optimistically!');

      expect(controller.messages.length, 1);
      expect(controller.messages.first.content, 'Hello Hive optimistically!');
      expect(controller.messages.first.status, 'sending');

      // Sending rows stay in the outbox, not room history — otherwise a
      // leave/re-open shows a clock bubble next to the acked copy.
      final cached = hiveService.getCachedMessages('conv_send');
      expect(cached, isEmpty);
      final pending = hiveService.getPendingMessages('conv_send');
      expect(pending.length, 1);
      expect(pending.first.content, 'Hello Hive optimistically!');
      expect(pending.first.status, 'sending');

      controller.onClose();
    });

    test('reopening a thread after ack does not show a leftover sending bubble', () {
      final now = DateTime.now().toIso8601String();
      hiveService.saveMessages('conv_reopen', [
        ChatMessageModel(
          id: 'server_kop',
          conversationId: 'conv_reopen',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'kop',
          status: 'sent',
          createdAt: now,
        ),
      ]);
      hiveService.addPendingMessage(
        'conv_reopen',
        ChatMessageModel(
          id: 'temp_stale_kop',
          conversationId: 'conv_reopen',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'kop',
          status: 'sending',
          createdAt: now,
        ),
      );

      final socket = Get.find<ChatSocketService>();
      socket.emitAckForTest(
        MessageAck(
          tempId: 'temp_stale_kop',
          message: ChatMessageModel(
            id: 'server_kop',
            conversationId: 'conv_reopen',
            sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
            content: 'kop',
            status: 'sent',
            createdAt: now,
          ),
        ),
      );

      final reopened = ChatController(
        fakeService,
        conversationId: 'conv_reopen',
        recipientId: null,
        other: ChatUserModel(id: 'u2', name: 'Bob'),
        storage: hiveService,
      );
      reopened.onInit();

      expect(reopened.messages.where((m) => m.content == 'kop').length, 1);
      expect(reopened.messages.single.status, 'sent');
      expect(hiveService.getPendingMessages('conv_reopen'), isEmpty);

      reopened.onClose();
    });

    test('ack after leaving the thread still clears the outbox', () {
      hiveService.addPendingMessage(
        'conv_left',
        ChatMessageModel(
          id: 'temp_left',
          conversationId: 'conv_left',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'zbbzbz',
          status: 'sending',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      Get.find<ChatSocketService>().emitAckForTest(
        MessageAck(
          tempId: 'temp_left',
          message: ChatMessageModel(
            id: 'server_left',
            conversationId: 'conv_left',
            sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
            content: 'zbbzbz',
            status: 'sent',
          ),
        ),
      );

      expect(hiveService.getPendingMessages('conv_left'), isEmpty);
      expect(hiveService.getCachedMessages('conv_left').single.id, 'server_left');
    });

    test('reconnection with loadMessages and _onAck does NOT duplicate message', () async {
      final controller = ChatController(
        fakeService,
        conversationId: 'conv_dedup',
        recipientId: null,
        other: ChatUserModel(id: 'u2', name: 'Bob'),
        storage: hiveService,
      );
      controller.onInit();

      // 1. User sends message offline
      controller.sendMessage('Offline message test');
      expect(controller.messages.length, 1);
      expect(controller.messages.first.id, isNotEmpty);

      // 2. Server has the message in DB with real server ID
      fakeService.messagesToReturn = [
        ChatMessageModel(
          id: 'server_msg_999',
          conversationId: 'conv_dedup',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'Offline message test',
          status: 'sent',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ];

      // 3. Online sync triggers loadMessages()
      await controller.loadMessages(silent: true);

      // Verify no duplicate in messages
      expect(controller.messages.length, 1);
      expect(controller.messages.first.id, 'server_msg_999');

      controller.onClose();
    });
  });

  group('Requirement 1: ChatListController Instant Loading & Hive Cache Sync', () {
    late HiveStorageService hiveService;
    late FakeChatService fakeService;

    setUp(() {
      Get.reset();
      hiveService = createTestHiveService();
      fakeService = FakeChatService();

      Get.put<HiveStorageService>(hiveService);
      Get.put<ChatSocketService>(ChatSocketService());

      final authCtrl = AuthController(FakeAuthService());
      authCtrl.userModelRx.value = UserModel(
        id: 'my_user_id',
        name: 'Me',
        email: 'me@example.com',
        role: 'user',
        status: 'active',
        createdAt: '2026-08-15T10:00:00.000Z',
      );
      Get.put<AuthController>(authCtrl);
    });

    tearDown(() {
      Get.reset();
    });

    test('loads cached conversations instantly on frame 0 from Hive without shimmer', () async {
      hiveService.saveConversations([
        ConversationModel(
          id: 'conv_1',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob', online: true),
          lastMessage: ChatMessageModel(
            id: 'm1',
            conversationId: 'conv_1',
            sender: ChatUserModel(id: 'u2', name: 'Bob'),
            content: 'Instant preview text from Hive',
          ),
          unreadCount: 2,
        ),
      ]);

      fakeService.conversationsToReturn = [
        ConversationModel(
          id: 'conv_1',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob', online: true),
          lastMessage: ChatMessageModel(
            id: 'm2',
            conversationId: 'conv_1',
            sender: ChatUserModel(id: 'u2', name: 'Bob'),
            content: 'Updated preview text from server',
          ),
          unreadCount: 2,
        ),
      ];

      final controller = ChatListController(fakeService, hiveService);
      controller.onInit();

      expect(controller.conversations.length, 1);
      expect(controller.conversations.first.otherParticipant?.name, 'Bob');
      expect(controller.conversations.first.lastMessage?.content, 'Instant preview text from Hive');
      expect(controller.showInitialShimmer, isFalse);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.conversations.first.lastMessage?.content, 'Updated preview text from server');
      expect(hiveService.getCachedConversations().first.lastMessage?.content, 'Updated preview text from server');

      controller.onClose();
    });

    test('incoming socket message updates conversation and writes to Hive', () {
      final controller = ChatListController(fakeService, hiveService);
      controller.conversations.assignAll([
        ConversationModel(
          id: 'conv_1',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob'),
          unreadCount: 0,
        ),
      ]);

      final incoming = ChatMessageModel(
        id: 'msg_new',
        conversationId: 'conv_1',
        sender: ChatUserModel(id: 'u2', name: 'Bob'),
        content: 'Realtime incoming msg to Hive',
        createdAt: '2026-08-15T10:30:00.000Z',
      );

      controller.bumpWithMessage(incoming);

      expect(controller.conversations.first.lastMessage?.content, 'Realtime incoming msg to Hive');
      expect(controller.conversations.first.unreadCount, 1);

      final cachedConvs = hiveService.getCachedConversations();
      expect(cachedConvs.first.lastMessage?.content, 'Realtime incoming msg to Hive');
      expect(cachedConvs.first.unreadCount, 1);

      final cachedMsgs = hiveService.getCachedMessages('conv_1');
      expect(cachedMsgs.any((m) => m.id == 'msg_new'), isTrue);

      controller.onClose();
    });

    test('ChatListController automatically updates preview and clears outbox when ACK arrives', () {
      final controller = ChatListController(fakeService, hiveService);
      hiveService.addPendingMessage(
        'conv_ack_test',
        ChatMessageModel(
          id: 'temp_outbox_ack',
          conversationId: 'conv_ack_test',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'Pending text',
          status: 'sending',
        ),
      );

      controller.conversations.assignAll([
        ConversationModel(
          id: 'conv_ack_test',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob'),
          lastMessage: ChatMessageModel(
            id: 'temp_outbox_ack',
            conversationId: 'conv_ack_test',
            sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
            content: 'Pending text',
            status: 'sending',
          ),
          unreadCount: 0,
        ),
      ]);

      expect(controller.conversations.first.lastMessage?.status, 'sending');
      expect(hiveService.getPendingMessages('conv_ack_test'), isNotEmpty);

      // Server acknowledges the message
      final ackMessage = ChatMessageModel(
        id: 'server_ack_id_100',
        conversationId: 'conv_ack_test',
        sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
        content: 'Pending text',
        status: 'sent',
      );

      controller.onAckReceived(
        MessageAck(tempId: 'temp_outbox_ack', message: ackMessage),
      );

      expect(controller.conversations.first.lastMessage?.status, 'sent');
      expect(controller.conversations.first.lastMessage?.id, 'server_ack_id_100');
      expect(hiveService.getPendingMessages('conv_ack_test'), isEmpty);

      controller.onClose();
    });

    test('fetchConversations keeps last queued outbox text as list preview', () async {
      hiveService.saveConversations([
        ConversationModel(
          id: 'conv_queue',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob'),
          lastMessage: ChatMessageModel(
            id: 'old_server',
            conversationId: 'conv_queue',
            sender: ChatUserModel(id: 'u2', name: 'Bob'),
            content: 'Old server preview',
            createdAt: '2026-08-15T10:00:00.000Z',
          ),
          lastActivityAt: '2026-08-15T10:00:00.000Z',
        ),
      ]);
      hiveService.addPendingMessage(
        'conv_queue',
        ChatMessageModel(
          id: 'temp_q1',
          conversationId: 'conv_queue',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'Queued first',
          status: 'sending',
          createdAt: '2026-08-15T10:01:00.000Z',
        ),
      );
      hiveService.addPendingMessage(
        'conv_queue',
        ChatMessageModel(
          id: 'temp_q2',
          conversationId: 'conv_queue',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'Queued last should show',
          status: 'sending',
          createdAt: '2026-08-15T10:02:00.000Z',
        ),
      );

      fakeService.conversationsToReturn = [
        ConversationModel(
          id: 'conv_queue',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob'),
          lastMessage: ChatMessageModel(
            id: 'old_server',
            conversationId: 'conv_queue',
            sender: ChatUserModel(id: 'u2', name: 'Bob'),
            content: 'Old server preview',
            createdAt: '2026-08-15T10:00:00.000Z',
          ),
          lastActivityAt: '2026-08-15T10:00:00.000Z',
        ),
      ];

      final controller = ChatListController(fakeService, hiveService);
      controller.onInit();

      expect(
        controller.conversations.first.lastMessage?.content,
        'Queued last should show',
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        controller.conversations.first.lastMessage?.content,
        'Queued last should show',
      );
      expect(controller.conversations.first.lastMessage?.status, 'sending');

      controller.onClose();
    });

    test('mid-queue ACK keeps last queued text as conversation preview', () {
      final controller = ChatListController(fakeService, hiveService);
      hiveService.addPendingMessage(
        'conv_mid',
        ChatMessageModel(
          id: 'temp_a',
          conversationId: 'conv_mid',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'First queued',
          status: 'sending',
          createdAt: '2026-08-15T10:01:00.000Z',
        ),
      );
      hiveService.addPendingMessage(
        'conv_mid',
        ChatMessageModel(
          id: 'temp_b',
          conversationId: 'conv_mid',
          sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
          content: 'Last queued',
          status: 'sending',
          createdAt: '2026-08-15T10:02:00.000Z',
        ),
      );

      controller.conversations.assignAll([
        ConversationModel(
          id: 'conv_mid',
          otherParticipant: ChatUserModel(id: 'u2', name: 'Bob'),
          lastMessage: ChatMessageModel(
            id: 'temp_b',
            conversationId: 'conv_mid',
            sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
            content: 'Last queued',
            status: 'sending',
          ),
          unreadCount: 0,
        ),
      ]);

      controller.onAckReceived(
        MessageAck(
          tempId: 'temp_a',
          message: ChatMessageModel(
            id: 'server_a',
            conversationId: 'conv_mid',
            sender: ChatUserModel(id: 'my_user_id', name: 'Me'),
            content: 'First queued',
            status: 'sent',
          ),
        ),
      );

      expect(controller.conversations.first.lastMessage?.content, 'Last queued');
      expect(controller.conversations.first.lastMessage?.status, 'sending');
      expect(hiveService.getPendingMessages('conv_mid').length, 1);
      expect(hiveService.getPendingMessages('conv_mid').first.id, 'temp_b');

      controller.onClose();
    });
  });

  group('Requirement 5: True Offline-First Architecture (Fast Offline Guard)', () {
    late HiveStorageService hiveService;
    late FakeHomeService fakeHomeService;
    late ConnectivityService connectivityService;

    setUp(() {
      Get.reset();
      hiveService = createTestHiveService();
      fakeHomeService = FakeHomeService();
      connectivityService = ConnectivityService();

      Get.put<HiveStorageService>(hiveService);
      Get.put<ConnectivityService>(connectivityService);
    });

    tearDown(() {
      Get.reset();
    });

    test('QuestionListController short-circuits and skips HTTP request when offline and cache exists', () async {
      // 1. Seed Hive cache
      hiveService.saveFeedList('home_feed_questions', [
        {
          '_id': 'q_offline_1',
          'content': 'Cached question',
          'options': [],
        }
      ]);

      // 2. Simulate Offline
      connectivityService.isOnline.value = false;
      connectivityService.isOffline.value = true;

      final controller = QuestionListController(fakeHomeService, hiveService);
      controller.onInit();

      expect(controller.questions.length, 1);
      expect(controller.questions.first.id, 'q_offline_1');

      await controller.fetchQuestions();

      // Verified: 0 HTTP API hits when offline!
      expect(fakeHomeService.getQuestionsCallCount, 0);

      controller.onClose();
    });

    test('AdListController short-circuits and skips HTTP request when offline', () async {
      // 1. Seed Hive cache
      hiveService.saveFeedList('home_feed_ads', [
        {
          '_id': 'ad_offline_1',
          'title': 'Cached banner ad',
          'image': 'ad.png',
        }
      ]);

      // 2. Simulate Offline
      connectivityService.isOnline.value = false;
      connectivityService.isOffline.value = true;

      final controller = AdListController(fakeHomeService, hiveService);
      controller.onInit();

      expect(controller.ads.length, 1);
      expect(controller.ads.first.id, 'ad_offline_1');

      await controller.fetchAds();

      // Verified: 0 HTTP API hits when offline!
      expect(fakeHomeService.getAdsCallCount, 0);

      controller.onClose();
    });

    test('ChatController: Sending identical message content when offline preserves duplicate text in outbox and displays as sending', () async {
      final fakeChatService = FakeChatService();
      final socket = ChatSocketService();
      Get.put<ChatSocketService>(socket);

      final authController = AuthController(FakeAuthService());
      authController.userModelRx.value = UserModel(
        id: 'my_id',
        name: 'Me',
        email: 'me@test.com',
        role: 'user',
        status: 'active',
        createdAt: '2026-01-01T00:00:00.000Z',
      );
      Get.put<AuthController>(authController);

      // Pre-seed an existing message with content "hello"
      hiveService.saveMessages('conv_dup_test', [
        ChatMessageModel(
          id: 'server_msg_1',
          conversationId: 'conv_dup_test',
          sender: ChatUserModel(id: 'my_id', name: 'Me'),
          content: 'hello',
          status: 'sent',
        ),
      ]);

      final chatController = ChatController(
        fakeChatService,
        conversationId: 'conv_dup_test',
        recipientId: null,
        other: ChatUserModel(id: 'other_id', name: 'Bob'),
        storage: hiveService,
      );

      chatController.onInit();

      expect(chatController.messages.length, 1);
      expect(chatController.messages.first.content, 'hello');
      expect(chatController.messages.first.status, 'sent');

      // Now send "hello" again while offline
      chatController.sendMessage('hello');

      // Both the original "hello" and the new optimistic sending "hello" must exist!
      expect(chatController.messages.length, 2);
      expect(chatController.messages[0].id, 'server_msg_1');
      expect(chatController.messages[0].status, 'sent');
      expect(chatController.messages[1].status, 'sending');
      expect(chatController.messages[1].content, 'hello');

      // Must be saved in persistent pending outbox
      final pending = hiveService.getPendingMessages('conv_dup_test');
      expect(pending.length, 1);
      expect(pending.first.content, 'hello');

      chatController.onClose();
    });

    test('ChatController: Sending identical message content when online renders optimistic bubble and reconciles on ACK', () async {
      final fakeChatService = FakeChatService();
      final socket = ChatSocketService();
      Get.put<ChatSocketService>(socket);

      final authController = AuthController(FakeAuthService());
      authController.userModelRx.value = UserModel(
        id: 'my_id',
        name: 'Me',
        email: 'me@test.com',
        role: 'user',
        status: 'active',
        createdAt: '2026-01-01T00:00:00.000Z',
      );
      Get.put<AuthController>(authController);

      final initialMsg = ChatMessageModel(
        id: 'server_hi_1',
        conversationId: 'conv_dup_online',
        sender: ChatUserModel(id: 'my_id', name: 'Me'),
        content: 'hi',
        status: 'sent',
      );

      // Pre-seed an existing message with content "hi"
      hiveService.saveMessages('conv_dup_online', [initialMsg]);
      fakeChatService.messagesToReturn = [initialMsg];

      final chatController = ChatController(
        fakeChatService,
        conversationId: 'conv_dup_online',
        recipientId: null,
        other: ChatUserModel(id: 'other_id', name: 'Bob'),
        storage: hiveService,
      );

      chatController.onInit();
      expect(chatController.messages.length, 1);

      // Send "hi" again
      chatController.sendMessage('hi');

      expect(chatController.messages.length, 2);
      final newTempId = chatController.messages[1].id;
      expect(chatController.messages[1].status, 'sending');

      // Receive server ACK for the new message
      final ackMessage = ChatMessageModel(
        id: 'server_hi_2',
        conversationId: 'conv_dup_online',
        sender: ChatUserModel(id: 'my_id', name: 'Me'),
        content: 'hi',
        status: 'sent',
      );

      socket.emitAckForTest(MessageAck(tempId: newTempId, message: ackMessage));
      await Future.delayed(Duration.zero);

      // Both messages are preserved with their distinct server IDs
      expect(chatController.messages.length, 2);
      expect(chatController.messages[0].id, 'server_hi_1');
      expect(chatController.messages[0].status, 'sent');
      expect(chatController.messages[1].id, 'server_hi_2');
      expect(chatController.messages[1].status, 'sent');

      chatController.onClose();
    });
  });
}
