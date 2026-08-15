import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/app_error_messages.dart';

/// App-wide error state with specialized, ultra-modern "No Internet"
/// handling when offline, and clean error recovery across all detail screens.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
  });

  const ErrorStateWidget.noInternet({
    super.key,
    this.message = 'No internet connection',
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
  });

  bool get _isNetworkError {
    final lower = message.toLowerCase();
    return lower.contains('internet') ||
        lower.contains('network') ||
        lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('timed out');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final friendly = AppErrorMessages.sanitize(message);

    if (_isNetworkError) {
      return _buildModernNoInternet(context, colorScheme, friendly);
    }

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 38,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Something Went Wrong",
              style: AppTextStyle.textLg(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Text(
                friendly,
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Ultra-modern, premium No Internet error state (Facebook / Airbnb style)
  Widget _buildModernNoInternet(
    BuildContext context,
    ColorScheme colorScheme,
    String friendlyMessage,
  ) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Layered glowing container
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon ?? Icons.wifi_off_rounded,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Internet Connection",
              style: AppTextStyle.textXl(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                "You're currently offline. Please check your network connection and try again.",
                style: AppTextStyle.textSm(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  retryLabel,
                  style: AppTextStyle.textSm(weight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
