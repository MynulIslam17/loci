import 'package:get/get.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';
import 'package:loci/features/browse_business/presentation/controllers/remove_saved_business_controller.dart';
import 'package:loci/features/recent_activity/domain/services/recent_activity_service.dart';
import 'package:loci/features/recent_activity/presentation/controllers/recent_activity_controller.dart';

class DrawerBindings extends Bindings {
  @override
  void dependencies() {
    // MyQrCodeController is registered permanently in AppBindings so its
    // QR is cached for the session â€” no per-visit registration here.
    Get.lazyPut(
      () => RecentActivityController(Get.find<RecentActivityService>()),
    );
    Get.lazyPut(
      () => RemoveSavedBusinessController(Get.find<BrowseBusinessService>()),
    );
  }
}
