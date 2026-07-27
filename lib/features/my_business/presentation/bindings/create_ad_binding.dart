import 'package:get/get.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';
import 'package:loci/features/my_business/presentation/controllers/create_ad_controller.dart';

class CreateAdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAdController>(
      () => CreateAdController(Get.find<MyBusinessService>()),
      fenix: true,
    );
  }
}
