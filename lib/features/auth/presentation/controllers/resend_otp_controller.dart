import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/features/auth/domain/services/auth_service.dart';

class ResendOtpController extends GetxController {
  final AuthService _service;

  ResendOtpController(this._service);

  final isLoading = false.obs;
  final canResend = true.obs;
  final secondsRemaining = 0.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  Timer? _timer;

  static final RegExp _waitSecondsRegex = RegExp(
    r'wait\s+(\d+)\s*second',
    caseSensitive: false,
  );

  Future<bool> resendOtp({required String email}) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.resendOtp(email: email);
      _startCountdown();
      return true;
    } catch (e) {
      final raw = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      final match = _waitSecondsRegex.firstMatch(raw);
      if (match != null) {
        final seconds = int.tryParse(match.group(1) ?? '') ?? 40;
        _startCountdown(seconds: seconds);
      }
      errorMessage.value = AppErrorMessages.sanitize(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _startCountdown({int seconds = 40}) {
    _timer?.cancel();
    canResend.value = false;
    secondsRemaining.value = seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsRemaining.value--;
      if (secondsRemaining.value <= 0) {
        _timer?.cancel();
        canResend.value = true;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
