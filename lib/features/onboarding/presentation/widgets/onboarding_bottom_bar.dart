import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Bottom navigation controls for the onboarding screen.
/// Includes a Skip button, animated pill page indicators, and a Next/Finish action button.
class OnboardingBottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
  });

  bool get isLastPage => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Skip Button (Smoothly fades out on the last page)
          AnimatedOpacity(
            opacity: isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: isLastPage,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: AppTextStyle.textMd(
                    color: colors.onSurfaceVariant,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // 2. Animated Pill Page Indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              totalPages,
              (index) {
                final isActive = currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  height: 8,
                  width: isActive ? 26 : 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),

          // 3. Next / Finish Animated Button
          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(isLastPage ? 24 : 28),
            child: InkWell(
              onTap: onNext,
              borderRadius: BorderRadius.circular(isLastPage ? 24 : 28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 52,
                padding: EdgeInsets.symmetric(
                  horizontal: isLastPage ? 20 : 14,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLastPage) ...[
                      Text(
                        'Get Started',
                        style: AppTextStyle.textSm(
                          color: colors.onPrimary,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      isLastPage
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      color: colors.onPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
