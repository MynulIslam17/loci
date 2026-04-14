import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class ForgetPassController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Send forgot password OTP to email
  Future<bool> sendForgotOtp({
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update(); // notify UI

    try {
      final NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.forgetPassword,
        body: {'email': email},
      );

      if (response.isSuccess && response.body != null ) {

        _successMessage = response.body!["message"] ?? "OTP sent successfully";
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to send OTP";
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
      return false;
    } finally {
      _isLoading = false;
      update(); // stop loading
    }
  }
}