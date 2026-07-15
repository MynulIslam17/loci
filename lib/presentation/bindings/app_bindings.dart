import 'package:get/get.dart';
import 'package:loci/presentation/controllers/browse_business/remove_saved_business_controller.dart';
import 'package:loci/presentation/controllers/comment/announcements_comment_controller.dart';
import 'package:loci/presentation/controllers/common/post_contoller.dart';
import 'package:loci/presentation/controllers/home/post_question_controller.dart';
import 'package:loci/presentation/controllers/home/question_list_controller.dart';

import '../../core/network/network_setup.dart';
import '../../core/services/stripe_service.dart';
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
    // ✅ global
    Get.put(AuthController(Get.find()), permanent: true);
    Get.put(NavController(), permanent: true);
    Get.put(setUpNetworkClient(), permanent: true);

    // Fetch the Stripe publishable key and initialize the SDK (fire-and-forget;
    // ready well before the user can reach checkout, which requires login).
    Get.put(StripeService(), permanent: true).init();

    Get.put(RSVPController(), permanent: true);
    Get.put(VoteController(), permanent: true);
    Get.put(PostQuestionController(), permanent: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}
