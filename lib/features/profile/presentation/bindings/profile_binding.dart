import 'package:get/get.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';
import 'package:loci/features/profile/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<ProfileService>();
    Get.lazyPut(() => ProfileController(service));
  }
}
