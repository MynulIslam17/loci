import 'package:get/get.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';
import 'package:loci/features/profile/presentation/controllers/change_password_controller.dart';
import 'package:loci/features/profile/presentation/controllers/delete_account_controller.dart';
import 'package:loci/features/profile/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<ProfileService>();
    Get.lazyPut(() => ProfileController(service));
    Get.lazyPut(() => ChangePasswordController(service));
    Get.lazyPut(
      () => DeleteAccountController(service, Get.find<AuthController>()),
    );
  }
}
