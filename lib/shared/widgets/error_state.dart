import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/app_error_messages.dart';

/// App-wide error state — matches the home / event / routes pattern:
/// outline icon, friendly message, optional "Try Again" text button.
///
/// Pass raw API / exception text; [AppErrorMessages] sanitizes it so
/// 502 / HTML / FormatException never reach the user.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final friendly = AppErrorMessages.sanitize(message);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              friendly,
              style: AppTextStyle.textSm(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
