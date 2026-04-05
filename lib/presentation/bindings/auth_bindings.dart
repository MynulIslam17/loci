
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:loci/presentation/controllers/auth/forget_pass_controller.dart';
import 'package:loci/presentation/controllers/auth/login_controller.dart';
import 'package:loci/presentation/controllers/auth/pass_reset_controller.dart';
import 'package:loci/presentation/controllers/auth/resend_otp_controller.dart';
import 'package:loci/presentation/controllers/auth/verify_email_controller.dart';

import '../controllers/auth/signup_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {

    // Page-specific
    Get.lazyPut(() => SignupController());
    Get.lazyPut(() => VerifyEmailController());
    Get.lazyPut(() => ResendOtpController());
    Get.lazyPut(() => ForgetPassController());
    Get.lazyPut(() => PassResetController());
    Get.lazyPut(() => LoginController());


  }
}