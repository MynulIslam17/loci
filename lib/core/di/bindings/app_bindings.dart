import 'package:get/get.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_setup.dart';
import 'package:loci/core/services/chat_socket_service.dart';
import 'package:loci/core/services/stripe_service.dart';
import 'package:loci/core/storage/local_storage_service.dart';
import 'package:loci/features/auth/data/repositories/auth_repository.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/browse_business/data/repositories/browse_business_repository.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';
import 'package:loci/features/chat/data/repositories/chat_repository.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:loci/features/common/data/repositories/common_repository.dart';
import 'package:loci/features/common/domain/services/common_service.dart';
import 'package:loci/features/community/data/repositories/community_repository.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/vote_controller.dart';
import 'package:loci/features/event/data/repositories/event_repository.dart';
import 'package:loci/features/event/domain/services/event_service.dart';
import 'package:loci/features/event/presentation/controllers/rsvp_controller.dart';
import 'package:loci/features/explore_activity/data/repositories/explore_activity_repository.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/home/data/repositories/home_repository.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/home/presentation/controllers/post_question_controller.dart';
import 'package:loci/features/my_business/data/repositories/my_business_repository.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';
import 'package:loci/features/network/data/repositories/network_repository.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/notification/data/repositories/notification_repository.dart';
import 'package:loci/features/notification/domain/services/notification_service.dart';
import 'package:loci/features/notification/presentation/controllers/notification_controller.dart';
import 'package:loci/features/profile/data/repositories/profile_repository.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';
import 'package:loci/features/qr_code/data/repositories/qr_code_repository.dart';
import 'package:loci/features/qr_code/domain/services/qr_code_service.dart';
import 'package:loci/features/qr_code/presentation/controllers/get_my_qr_controller.dart';
import 'package:loci/features/raffles/data/repositories/raffles_repository.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';
import 'package:loci/features/recent_activity/data/repositories/recent_activity_repository.dart';
import 'package:loci/features/recent_activity/domain/services/recent_activity_service.dart';
import 'package:loci/features/routes/data/repositories/routes_repository.dart';
import 'package:loci/features/routes/domain/services/routes_service.dart';
import 'package:loci/features/subscription/data/repositories/subscription_repository.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';

/// App-wide permanent dependencies.
///
/// Order mirrors the reference Injection:
/// storage → network → auth session → feature repos/services → shared controllers.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Storage
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);

    // Network (token callback is lazy — safe before AuthController exists)
    Get.put<NetworkCaller>(setUpNetworkClient(), permanent: true);

    // Auth session (must be available before feature flows)
    Get.put<AuthRepository>(
      AuthRepository(
        Get.find<NetworkCaller>(),
        Get.find<LocalStorageService>(),
      ),
      permanent: true,
    );
    Get.put<AuthService>(
      AuthService(Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );

    // Feature repositories + services
    Get.put<HomeRepository>(
      HomeRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<HomeService>(
      HomeService(Get.find<HomeRepository>()),
      permanent: true,
    );

    Get.put<CommunityRepository>(
      CommunityRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<CommunityService>(
      CommunityService(Get.find<CommunityRepository>()),
      permanent: true,
    );

    Get.put<MyBusinessRepository>(
      MyBusinessRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<MyBusinessService>(
      MyBusinessService(Get.find<MyBusinessRepository>()),
      permanent: true,
    );

    Get.put<BrowseBusinessRepository>(
      BrowseBusinessRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<BrowseBusinessService>(
      BrowseBusinessService(Get.find<BrowseBusinessRepository>()),
      permanent: true,
    );

    Get.put<ExploreActivityRepository>(
      ExploreActivityRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<ExploreActivityService>(
      ExploreActivityService(Get.find<ExploreActivityRepository>()),
      permanent: true,
    );

    Get.put<EventRepository>(
      EventRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<EventService>(
      EventService(Get.find<EventRepository>()),
      permanent: true,
    );

    Get.put<RoutesRepository>(
      RoutesRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<RoutesService>(
      RoutesService(Get.find<RoutesRepository>()),
      permanent: true,
    );

    Get.put<RafflesRepository>(
      RafflesRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<RafflesService>(
      RafflesService(Get.find<RafflesRepository>()),
      permanent: true,
    );

    Get.put<NetworkRepository>(
      NetworkRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<NetworkService>(
      NetworkService(Get.find<NetworkRepository>()),
      permanent: true,
    );

    Get.put<ChatRepository>(
      ChatRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<ChatService>(
      ChatService(Get.find<ChatRepository>()),
      permanent: true,
    );

    Get.put<ProfileRepository>(
      ProfileRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<ProfileService>(
      ProfileService(Get.find<ProfileRepository>()),
      permanent: true,
    );

    Get.put<SubscriptionRepository>(
      SubscriptionRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<SubscriptionService>(
      SubscriptionService(Get.find<SubscriptionRepository>()),
      permanent: true,
    );

    Get.put<NotificationRepository>(
      NotificationRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<NotificationService>(
      NotificationService(Get.find<NotificationRepository>()),
      permanent: true,
    );

    Get.put<CommonRepository>(
      CommonRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<CommonService>(
      CommonService(Get.find<CommonRepository>()),
      permanent: true,
    );

    Get.put<QrCodeRepository>(
      QrCodeRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<QrCodeService>(
      QrCodeService(Get.find<QrCodeRepository>()),
      permanent: true,
    );

    Get.put<RecentActivityRepository>(
      RecentActivityRepository(Get.find<NetworkCaller>()),
      permanent: true,
    );
    Get.put<RecentActivityService>(
      RecentActivityService(Get.find<RecentActivityRepository>()),
      permanent: true,
    );

    // Shared realtime / payments / nav
    Get.put<ChatSocketService>(ChatSocketService(), permanent: true);
    Get.put<NavController>(NavController(), permanent: true);
    Get.put<StripeService>(StripeService(), permanent: true);

    Get.lazyPut<ChatListController>(
      () => ChatListController(Get.find<ChatService>()),
      fenix: true,
    );

    // Controllers reused across many routes
    Get.put<RSVPController>(
      RSVPController(Get.find<EventService>()),
      permanent: true,
    );
    Get.put<VoteController>(
      VoteController(Get.find<CommunityService>()),
      permanent: true,
    );
    Get.put<PostQuestionController>(
      PostQuestionController(Get.find<HomeService>()),
      permanent: true,
    );
    // Kept alive so the user's QR is fetched once per session and served from
    // memory on subsequent drawer visits (cleared on logout).
    Get.put<GetMyQrCodeController>(
      GetMyQrCodeController(Get.find<QrCodeService>()),
      permanent: true,
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationService>()),
      fenix: true,
    );
  }
}
