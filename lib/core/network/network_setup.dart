



import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/routes/app_routes.dart';

import '../../presentation/controllers/auth/auth_controller.dart';
import 'network_caller.dart';

NetworkCaller setUpNetworkClient() {
  return NetworkCaller(
      onUnAuthorize: _onUnAuthorize,
      accessToken: () => Get.find<AuthController>().accessToken ?? ""
  );
}

Future<void> _onUnAuthorize() async {
  Get.offAllNamed(AppRoutes.login); // Go to login if token invalid
}