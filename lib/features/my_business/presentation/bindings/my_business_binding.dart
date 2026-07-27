import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/community_qr_controller.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';
import 'package:loci/features/my_business/presentation/controllers/business_claim_controller.dart';
import 'package:loci/features/my_business/presentation/controllers/business_review_controller.dart';
import 'package:loci/features/my_business/presentation/controllers/find_google_business_controller.dart';
import 'package:loci/features/my_business/presentation/controllers/get_my_business_list_controller.dart';
import 'package:loci/features/my_business/presentation/controllers/my_business_profile_controller.dart';

class MyBusinessBindings extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<MyBusinessService>();
    Get.lazyPut(() => GetMyBusinessController(service));
    Get.lazyPut(() => MyBusinessProfileController(service));
    Get.lazyPut(() => BusinessClaimController(service));
    Get.lazyPut(() => MyBusinessReviewController(service));
    Get.lazyPut(() => FindGoogleBusinessController(service));
    Get.lazyPut(() => CommunityQrController(Get.find<CommunityService>()));
  }
}
