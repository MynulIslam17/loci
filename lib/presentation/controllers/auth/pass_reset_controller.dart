import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class PassResetController extends GetxController {
  // -----------------------------
  // State variables
  // -----------------------------
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // -----------------------------
  // Reset password API
  // -----------------------------
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update();

    try {
      final NetworkResponse response = await Get.find<NetworkCaller>()
          .postRequest(
        url: AppUrl.resetPassword,
        body: {"email": email, "newPassword": newPassword},
      );

      if (response.isSuccess && response.body != null) {
        _successMessage =
            response.body!["message"] ?? "Password reset successfully";
        return true;
      } else if (response.statusCode == 422) {
        final errors = response.body?["errors"];
        if (errors != null && errors is Map) {
          final firstError = (errors.values.first as List).first;
          _errorMessage = firstError;
        } else {
          _errorMessage = response.body?["message"] ?? "Validation failed";
        }
        return false;
      } else {
        _errorMessage = response.errorMessage ?? "Password reset failed";
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }
}
