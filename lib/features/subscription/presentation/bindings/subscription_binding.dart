import 'package:get/get.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MySubscriptionController>(
      () => MySubscriptionController(
        Get.find<SubscriptionStatusController>(),
        Get.find<SubscriptionService>(),
      ),
    );
  }
}
