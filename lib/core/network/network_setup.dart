import 'package:get/get.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/routes/app_routes.dart';

import 'network_caller.dart';

NetworkCaller setUpNetworkClient() {
  return NetworkCaller(
    onUnAuthorize: _onUnAuthorize,
    accessToken: _readAccessToken,
  );
}

String _readAccessToken() {
  if (!Get.isRegistered<AuthController>()) return '';
  return Get.find<AuthController>().accessToken ?? '';
}

/// Fires on any 401 when a token was sent. Clears the local session and
/// sends the user back to login so they can re-authenticate.
bool _isHandlingUnauthorized = false;

Future<void> _onUnAuthorize() async {
  if (_isHandlingUnauthorized) return;
  _isHandlingUnauthorized = true;
  try {
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().logout();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  } finally {
    _isHandlingUnauthorized = false;
  }
}
