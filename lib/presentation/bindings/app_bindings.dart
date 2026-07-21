import 'package:get/get.dart';
import 'package:loci/presentation/controllers/browse_business/remove_saved_business_controller.dart';
import 'package:loci/presentation/controllers/comment/announcements_comment_controller.dart';
import 'package:loci/presentation/controllers/common/post_contoller.dart';
import 'package:loci/presentation/controllers/home/post_question_controller.dart';
import 'package:loci/presentation/controllers/home/question_list_controller.dart';

import '../../core/network/network_setup.dart';
import '../../core/services/chat_socket_service.dart';
import '../../core/services/stripe_service.dart';
import '../controllers/chat/chat_list_controller.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../controllers/auth/auth_controller.dart';
import '../controllers/community/vote_controller.dart';
import '../controllers/event/rsvp_controller.dart';
import '../controllers/nav_controller.dart';
import '../controllers/notification/notification_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.put(LocalStorageService(), permanent: true);
    Get.put(AuthRepository(Get.find()), permanent: true);
    // Register the chat socket BEFORE AuthController so its async loadUserData()
    // can connect the socket once a stored token is loaded on startup.
    Get.put(ChatSocketService(), permanent: true);
    // ✅ global
    Get.put(AuthController(Get.find()), permanent: true);
    Get.put(NavController(), permanent: true);
    Get.put(setUpNetworkClient(), permanent: true);
    Get.lazyPut<ChatListController>(() => ChatListController(), fenix: true);

    // Register the Stripe service, but DON'T init here — its config fetch needs
    // network + login. AuthController calls .init() after authentication, so the
    // login screen never triggers a pre-login request (no cold-start errors).
    Get.put(StripeService(), permanent: true);

    Get.put(RSVPController(), permanent: true);
    Get.put(VoteController(), permanent: true);
    Get.put(PostQuestionController(), permanent: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}
