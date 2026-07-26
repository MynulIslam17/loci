import 'package:get/get.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/subscription/presentation/controllers/my_subscription_controller.dart';

class MySubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MySubscriptionController>(
      () => MySubscriptionController(Get.find<SubscriptionService>()),
    );
  }
}
