import 'package:get/get.dart';

import '../../core/network/network_setup.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../controllers/auth/auth_controller.dart';
import '../controllers/nav_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.put(LocalStorageService(), permanent: true);
    Get.put(AuthRepository(Get.find()), permanent: true);
    // ✅ global
    Get.put(AuthController(Get.find()), permanent: true);
    Get.put(NavController(), permanent: true);
    Get.put(setUpNetworkClient(), permanent: true);



  }
}
