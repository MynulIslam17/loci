import 'dart:async';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class ResendOtpController extends GetxController {
  bool _isLoading = false;
  bool _canResend = true;
  int _secondsRemaining = 0;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  bool get canResend => _canResend;
  int get secondsRemaining => _secondsRemaining;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Timer? _timer;

  Future<bool> resendOtp({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update();

    try {
      final NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.resendOtp,
        body: {'email': email},
      );

      if (response.isSuccess && response.body != null) {
        _successMessage = response.body!["message"] ?? "OTP Re-sent successfully";
        _startCountdown();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to resend OTP";
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

  void _startCountdown() {
    _canResend = false;
    _secondsRemaining = 40;
    update();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsRemaining--;
      update();

      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        _canResend = true;
        update();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}