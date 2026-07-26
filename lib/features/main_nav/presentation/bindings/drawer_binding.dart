import 'package:get/get.dart';
import 'package:loci/features/browse_business/domain/services/browse_business_service.dart';
import 'package:loci/features/browse_business/presentation/controllers/remove_saved_business_controller.dart';
import 'package:loci/features/recent_activity/domain/services/recent_activity_service.dart';
import 'package:loci/features/recent_activity/presentation/controllers/recent_activity_controller.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/subscription/presentation/controllers/plans_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_checkout_controller.dart';

class DrawerBindings extends Bindings {
  @override
  void dependencies() {
    // GetMyQrCodeController is registered permanently in AppBindings so its
    // QR is cached for the session — no per-visit registration here.
    Get.lazyPut(
      () => RecentActivityController(Get.find<RecentActivityService>()),
    );
    // Permanent (guarded so they're built once) so plans + subscription stay
    // cached across navigation — revisiting the subscription page no longer
    // refetches and reshows the shimmer. Pull-to-refresh still forces a reload.
    if (!Get.isRegistered<PlansController>()) {
      Get.put(
        PlansController(Get.find<SubscriptionService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<SubscriptionCheckoutController>()) {
      Get.put(
        SubscriptionCheckoutController(Get.find<SubscriptionService>()),
        permanent: true,
      );
    }
    Get.lazyPut(
      () => RemoveSavedBusinessController(Get.find<BrowseBusinessService>()),
    );
  }
}
