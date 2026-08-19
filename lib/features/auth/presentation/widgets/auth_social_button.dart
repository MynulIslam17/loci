import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

enum SocialProvider { google, apple }

/// Premium social authentication button (Google, Apple) styled with
/// 16px squircle borders, subtle elevations, and haptic feedback.
class AuthSocialButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final String? customText;
  final bool isLoading;

  const AuthSocialButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.customText,
    this.isLoading = false,
  });

  const AuthSocialButton.google({
    super.key,
    this.onPressed,
    this.customText,
    this.isLoading = false,
  }) : provider = SocialProvider.google;

  const AuthSocialButton.apple({
    super.key,
    this.onPressed,
    this.customText,
    this.isLoading = false,
  }) : provider = SocialProvider.apple;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isGoogle = provider == SocialProvider.google;
    final label = customText ??
        (isGoogle ? 'Continue with Google' : 'Sign in with Apple');

    // Apple button styling follows Apple Human Interface Guidelines:
    // In light mode: Solid black with white icon/text.
    // In dark mode: Solid white with black icon/text.
    final appleBg = isDark ? Colors.white : const Color(0xFF000000);
    final appleFg = isDark ? const Color(0xFF000000) : Colors.white;

    final bgColor = isGoogle ? colors.surfaceContainerLow : appleBg;
    final textColor = isGoogle ? colors.onSurface : appleFg;
    final borderColor = isGoogle
        ? colors.outlineVariant.withValues(alpha: 0.5)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                if (onPressed != null) {
                  onPressed!();
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isGoogle)
                        SvgPicture.asset(
                          'assets/icons/google.svg',
                          width: 20,
                          height: 20,
                        )
                      else
                        SvgPicture.asset(
                          'assets/icons/apple.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            appleFg,
                            BlendMode.srcIn,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: AppTextStyle.textSm(
                          color: textColor,
                          weight: FontWeight.w600,
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
