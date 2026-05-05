import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';



class SnackbarService {
  // Debounce to prevent spam (500ms cooldown)
  static final Duration _debounceDuration = Duration(milliseconds: 500);
  static DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);

  static bool _canShow() {
    final now = DateTime.now();
    if (now.difference(_lastShown) < _debounceDuration) {
      return false;
    }
    _lastShown = now;
    return true;
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    IconData? icon,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    TextButton? mainButton,
  }) {
    if (Get.isSnackbarOpen) return;
    if (!_canShow()) return;

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: icon != null ? Icon(icon, color: Colors.white) : null,
      duration: duration,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      shouldIconPulse: icon != null,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      onTap: (_) => onTap?.call(),
      mainButton: mainButton,
    );
  }

  // ===== Pre-built helpers =====

  static void success(String message, {String title = "Success"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
      position: SnackPosition.TOP,
    );
  }

  static void error(
      String message, {
        String title = "Error",
        VoidCallback? onRetry,
      }) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.danger,
      icon: Icons.error,
      duration: const Duration(seconds: 5),
      mainButton: onRetry != null
          ? TextButton(
        onPressed: () {
          Get.back(); // Close snackbar first
          Future.delayed(Duration.zero, onRetry); // Execute after frame
        },
        child: const Text(
          "RETRY",
          style: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
    );
  }

  static void warning(String message, {String title = "Warning"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  static void info(String message, {String title = "Info"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info,
      position: SnackPosition.TOP,
    );
  }

  static void custom({
    required String message,
    String? title,
    required Color backgroundColor,
    IconData? icon,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    TextButton? mainButton, // ✅ Changed from Widget? to TextButton?
  }) {
    _show(
      title: title ?? "",
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      position: position,
      duration: duration,
      onTap: onTap,
      mainButton: mainButton, // ✅ Changed parameter name
    );
  }

  static void loading(String message) {
    if (!_canShow()) return;

    Get.snackbar(
      "Please wait",
      message,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      icon: const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
      duration: const Duration(seconds: 30),
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: false,
      shouldIconPulse: false,
      barBlur: 0, // Prevent blur on progress indicator
    );
  }

  static void dismissAll() => Get.closeAllSnackbars();
}