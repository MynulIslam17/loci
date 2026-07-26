import 'package:get/get.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';
import 'package:loci/features/auth/presentation/controllers/forget_pass_controller.dart';
import 'package:loci/features/auth/presentation/controllers/login_controller.dart';
import 'package:loci/features/auth/presentation/controllers/pass_reset_controller.dart';
import 'package:loci/features/auth/presentation/controllers/resend_otp_controller.dart';
import 'package:loci/features/auth/presentation/controllers/signup_controller.dart';
import 'package:loci/features/auth/presentation/controllers/verify_email_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<AuthService>();
    Get.lazyPut(() => SignupController(service));
    Get.lazyPut(() => VerifyEmailController(service));
    Get.lazyPut(() => ResendOtpController(service));
    Get.lazyPut(() => ForgetPassController(service));
    Get.lazyPut(() => PassResetController(service));
    Get.lazyPut(() => LoginController(service));
  }
}
