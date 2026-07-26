import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';

/// Drives `PATCH /users/me/password`.
class ChangePasswordController extends GetxController {
  ChangePasswordController(this._service);

  final ProfileService _service;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  /// Returns true on success so the screen can pop.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isLoading.value) return false;
    _isLoading.value = true;
    try {
      final message = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      SnackbarService.success(message);
      return true;
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
