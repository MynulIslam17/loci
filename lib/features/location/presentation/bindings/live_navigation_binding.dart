import 'package:get/get.dart';
import 'package:loci/features/location/presentation/controllers/live_navigation_controller.dart';

class LiveNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveNavigationController>(() => LiveNavigationController());
  }
}
