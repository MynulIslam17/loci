import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/core/utils/app_error_messages.dart';

import '../theme/app_colors.dart';

class SnackbarService {
  /// App-level hook run before an error snackbar is shown. Return true to
  /// swallow the snackbar (e.g. the subscription paywall sheet handled it).
  static bool Function(String message)? errorInterceptor;

  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);

  static const Color _surface = Color(0xFF2C2C2E);
  static const Color _textPrimary = Color(0xFFF5F5F7);
  static const Color _textSecondary = Color(0xFFB0B0B5);

  static bool _canShow() {
    final now = DateTime.now();
    if (now.difference(_lastShown) < _debounceDuration) {
      return false;
    }
    _lastShown = now;
    return true;
  }

  static bool _isGenericTitle(String title) {
    return title == 'Success' ||
        title == 'Warning' ||
        title == 'Info' ||
        title == 'Please wait';
  }

  static ({String primary, String? secondary}) _copyLines({
    required String title,
    required String message,
  }) {
    final trimmedTitle = title.trim();
    final trimmedMessage = message.trim();

    if (_isGenericTitle(trimmedTitle) || trimmedTitle.isEmpty) {
      return (primary: trimmedMessage, secondary: null);
    }

    if (trimmedMessage.isEmpty || trimmedMessage == trimmedTitle) {
      return (primary: trimmedTitle, secondary: null);
    }

    return (primary: trimmedTitle, secondary: trimmedMessage);
  }

  static Widget _content({
    required String primary,
    String? secondary,
    required Color accent,
    IconData? icon,
    Widget? leading,
  }) {
    return Row(
      children: [
        Container(
          width: 3,
          height: secondary == null ? 32 : 40,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        if (leading != null) ...[
          leading,
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: _textPrimary.withValues(alpha: 0.9)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                primary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textSm(
                  color: _textPrimary,
                  weight: FontWeight.w500,
                ),
              ),
              if (secondary != null) ...[
                const SizedBox(height: 2),
                Text(
                  secondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textXs(color: _textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color accent,
    IconData? icon,
    Widget? leading,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    TextButton? mainButton,
    bool isDismissible = true,
  }) {
    if (Get.isSnackbarOpen) return;
    if (!_canShow()) return;

    final lines = _copyLines(title: title, message: message);

    Get.snackbar(
      '',
      '',
      snackPosition: position,
      backgroundColor: _surface,
      colorText: _textPrimary,
      titleText: const SizedBox.shrink(),
      messageText: _content(
        primary: lines.primary,
        secondary: lines.secondary,
        accent: accent,
        icon: icon,
        leading: leading,
      ),
      duration: duration,
      borderRadius: 10,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 220),
      shouldIconPulse: false,
      isDismissible: isDismissible,
      dismissDirection: DismissDirection.horizontal,
      barBlur: 0,
      maxWidth: 420,
      onTap: (_) => onTap?.call(),
      mainButton: mainButton,
    );
  }

  static void success(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      accent: AppColors.primaryG500,
      icon: Icons.check_rounded,
      position: SnackPosition.TOP,
    );
  }

  static void error(String message, {String? title, VoidCallback? onRetry}) {
    // If the device is offline, the persistent floating pill already communicates offline status.
    // Suppress redundant error snackbars.
    if (ConnectivityService.isCurrentOffline) {
      final lower = message.toLowerCase();
      if (lower.contains('internet') ||
          lower.contains('network') ||
          lower.contains('socketexception') ||
          lower.contains('connection') ||
          lower.contains('went wrong')) {
        return;
      }
    }

    final friendly = AppErrorMessages.sanitize(message);

    if (errorInterceptor?.call(friendly) ?? false) return;

    _show(
      title: title ?? AppErrorMessages.titleFor(message: friendly),
      message: friendly,
      accent: AppColors.danger,
      icon: AppErrorMessages.iconFor(message: friendly),
      duration: const Duration(seconds: 4),
      mainButton: onRetry != null
          ? TextButton(
              onPressed: () {
                Get.back();
                Future.delayed(Duration.zero, onRetry);
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                'Retry',
                style: AppTextStyle.textXs(
                  color: _textPrimary,
                  weight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  static void warning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: AppErrorMessages.sanitize(message),
      accent: const Color(0xFFE8A020),
      icon: Icons.error_outline_rounded,
    );
  }

  static void info(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      accent: const Color(0xFF5B9BD5),
      icon: Icons.info_outline_rounded,
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
    TextButton? mainButton,
  }) {
    _show(
      title: title ?? '',
      message: message,
      accent: backgroundColor,
      icon: icon,
      position: position,
      duration: duration,
      onTap: onTap,
      mainButton: mainButton,
    );
  }

  static void loading(String message) {
    if (!_canShow()) return;

    _show(
      title: 'Please wait',
      message: message,
      accent: _textSecondary,
      leading: const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(_textPrimary),
        ),
      ),
      duration: const Duration(seconds: 30),
      position: SnackPosition.BOTTOM,
      isDismissible: false,
    );
  }

  static void dismissAll() => Get.closeAllSnackbars();
}
