import 'package:get/get.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';
import 'package:loci/features/browse_business/presentation/controllers/all_reviews_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/browse_business_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/business_profile_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/post_review_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/review_preview_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/save_business_controller.dart';

class BrowseBusinessBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<BrowseBusinessService>();
    Get.lazyPut(() => BrowseBusinessController(service));
    Get.lazyPut(() => BusinessProfileController(service));
    Get.lazyPut(() => AllReviewsController(service));
    Get.lazyPut(() => ReviewPreviewController(service));
    Get.lazyPut(() => SaveBusinessController(service));
    Get.lazyPut(() => PostReviewController(service));
  }
}

/// Backward-compatible alias for route bindings.
typedef BrowseBusinessBindings = BrowseBusinessBinding;
