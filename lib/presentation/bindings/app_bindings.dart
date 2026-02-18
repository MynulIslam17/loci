import 'package:get/get.dart';

import '../controllers/nav_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.put(NavController());



  }
}
