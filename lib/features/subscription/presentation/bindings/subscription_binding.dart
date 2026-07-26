import 'package:get/get.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/subscription/presentation/controllers/plans_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_checkout_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    final SubscriptionService service = Get.find<SubscriptionService>();
    Get.lazyPut<PlansController>(() => PlansController(service));
    Get.lazyPut<SubscriptionCheckoutController>(
      () => SubscriptionCheckoutController(service),
    );
    Get.lazyPut<SubscriptionController>(
      () => SubscriptionController(service),
      fenix: true,
    );
  }
}
