import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/features/chat/data/models/chat_user_model.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:loci/features/chat/presentation/controllers/new_chat_controller.dart';
import 'package:loci/features/chat/presentation/widgets/new_chat_sheet.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/data/models/dashboard_activity.dart';
import 'package:loci/features/network/data/models/dashboard_count.dart';
import 'package:loci/features/network/data/models/dashboard_data.dart';
import 'package:loci/features/network/data/models/dashboard_response.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class _FakeChatService extends Fake implements ChatService {
  @override
  Future<ConversationModel> createConversation(String participantId) async {
    return ConversationModel(
      id: 'conv_123',
      participants: [
        ChatParticipant(user: ChatUserModel(id: 'u1', name: 'User One')),
        ChatParticipant(user: ChatUserModel(id: participantId, name: 'Connection User')),
      ],
      unreadCount: 3,
    );
  }

  @override
  Future<ConversationsPage> getConversations({int page = 1, int limit = 20}) async {
    return ConversationsPage(
      conversations: [
        ConversationModel(
          id: 'conv_123',
          participants: [ChatParticipant(user: ChatUserModel(id: 'u2', name: 'User Two'))],
          unreadCount: 5,
        ),
      ],
      page: 1,
      hasNextPage: false,
    );
  }

  @override
  Future<void> notifyDelivered() async {}
}

class _FakeNetworkService extends Fake implements NetworkService {
  @override
  Future<DashboardResponse> getDashboard(NetworkType type) async {
    return DashboardResponse(
      success: true,
      message: 'OK',
      data: DashboardData(
        counts: DashboardCounts.fromJson({}),
        activity: DashboardActivity(
          type: NetworkType.connections,
          data: [
            ConnectionModel(
              id: 'c1',
              name: 'John Doe',
              organization: 'Acme Corp',
              userId: 'u_john',
              avatar: '',
              email: 'john@example.com',
              phone: '1234567890',
              connectedAt: '',
            ),
          ],
          meta: PaginationMeta(
            page: 1,
            limit: 10,
            total: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          ),
        ),
      ),
    );
  }
}

class _FakeHiveStorageService extends Fake implements HiveStorageService {
  @override
  List<ConversationModel> getCachedConversations() => [];

  @override
  Future<void> saveConversations(List<ConversationModel> conversations) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeChatService chatService;
  late _FakeNetworkService networkService;
  late _FakeHiveStorageService storageService;
  late ChatListController chatListController;
  late NewChatController newChatController;

  setUp(() {
    Get.reset();
    Get.put<ChatSocketService>(ChatSocketService());
    chatService = _FakeChatService();
    networkService = _FakeNetworkService();
    storageService = _FakeHiveStorageService();

    chatListController = ChatListController(chatService, storageService);
    Get.put<ChatListController>(chatListController);

    newChatController = NewChatController(networkService, chatService);
    Get.put<NewChatController>(newChatController);
  });

  tearDown(() {
    Get.reset();
  });

  group('ChatListController clearUnread Tests', () {
    test('clearUnread updates unreadCount to 0 safely', () {
      chatListController.conversations.assignAll([
        ConversationModel(
          id: 'conv_123',
          participants: [ChatParticipant(user: ChatUserModel(id: 'u2', name: 'User Two'))],
          unreadCount: 5,
        ),
      ]);

      expect(chatListController.conversations.first.unreadCount, 5);
      chatListController.clearUnread('conv_123');
      expect(chatListController.conversations.first.unreadCount, 0);
    });

    testWidgets('clearUnread called during build does not throw setState during build exception', (tester) async {
      chatListController.conversations.assignAll([
        ConversationModel(
          id: 'conv_123',
          participants: [ChatParticipant(user: ChatUserModel(id: 'u2', name: 'User Two'))],
          unreadCount: 5,
        ),
      ]);

      // A widget whose build method invokes clearUnread while an Obx is listening
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Obx(() => Text('Unread: ${chatListController.conversations.first.unreadCount}')),
              Builder(
                builder: (context) {
                  // Simulate onInit or build invocation
                  chatListController.clearUnread('conv_123');
                  return const Text('Child');
                },
              ),
            ],
          ),
        ),
      );

      // Verify no exception was thrown during build phase
      expect(tester.takeException(), isNull);
      await tester.pump();
      expect(find.text('Unread: 0'), findsOneWidget);
    });
  });

  group('NewChatSheet UI & Shimmer Tests', () {
    testWidgets('renders shimmer without CircularProgressIndicator when loading connections', (tester) async {
      newChatController.isLoading.value = true;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NewChatSheet(),
          ),
        ),
      );

      // Must NOT contain CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Must contain SkeletonBox for shimmer user style
      expect(find.byType(SkeletonBox), findsWidgets);
    });

    testWidgets('renders user list and shows shimmer on trailing when starting a chat without CircularProgressIndicator', (tester) async {
      newChatController.isLoading.value = false;
      newChatController.connections.assignAll([
        ConnectionModel(
          id: 'c1',
          name: 'John Doe',
          organization: 'Acme Corp',
          userId: 'u_john',
          avatar: '',
          email: 'john@example.com',
          phone: '1234567890',
          connectedAt: '',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NewChatSheet(),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Set startingUserId to simulate user tap
      newChatController.startingUserId.value = 'u_john';
      await tester.pump();

      // Trailing should show SkeletonBox, still NO CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SkeletonBox), findsOneWidget);
    });
  });
}
