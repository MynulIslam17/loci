import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/gen/assets.gen.dart';

/// Shown in place of the ads carousel when `/ads` has nothing to show — either
/// because it's genuinely empty or because the server is unreachable (502 etc).
///
/// Replaces the old behaviour of stuffing the app logo into a full-bleed
/// `BoxFit.cover` carousel card (which stretched/cropped it and looked broken).
/// Instead it's a purpose-built branded card: a contained logo mark on a soft
/// gradient, with a message that adapts to the empty vs error case and an
/// optional tap-to-retry.
class CarouselFallbackBanner extends StatelessWidget {
  /// True when the ads request failed (server down / network), as opposed to a
  /// successful-but-empty response. Only changes the copy + retry affordance.
  final bool isError;
  final VoidCallback? onRetry;

  const CarouselFallbackBanner({super.key, this.isError = false, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final cardWidth = MediaQuery.sizeOf(context).width * 0.85;

    final title = isError
        ? AppErrorMessages.serverTitle
        : 'Discover local businesses';
    final subtitle = isError
        ? AppErrorMessages.serverUnavailable
        : 'Featured spots will appear here soon.';

    return SizedBox(
      height: 208,
      child: Center(
        child: GestureDetector(
          onTap: isError ? onRetry : null,
          child: Container(
            width: cardWidth,
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.12),
                  colorScheme.primary.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                // Contained logo mark — shown at its true aspect ratio inside a
                // rounded tile, never stretched across the whole banner.
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    Assets.images.logoPng.path,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle.textMd(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isError && onRetry != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to retry',
                              style: AppTextStyle.textSm(
                                color: colorScheme.primary,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
