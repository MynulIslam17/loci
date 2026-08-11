import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';

/// Drives `DELETE /users/me/delete`. On success the session is cleared and the
/// user is sent back to login via [AuthController.logout].
class DeleteAccountController extends GetxController {
  DeleteAccountController(this._service, this._auth);

  final ProfileService _service;
  final AuthController _auth;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  Future<void> deleteAccount(String password) async {
    if (_isLoading.value) return;
    _isLoading.value = true;
    try {
      await _service.deleteAccount(password);
      // logout() clears the session and navigates to login (offAll), which
      // tears down this screen — so no need to reset _isLoading here.
      await _auth.logout();
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
      _isLoading.value = false;
    }
  }
}
