import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/gen/assets.gen.dart';

/// Centered logo and title header for single-step auth screens
/// (Forgot Password, OTP Verification, Reset Password).
class AuthLogoHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? customSubtitle;

  const AuthLogoHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          Assets.images.logoPng.path,
          height: 84,
          width: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 36),
        Text(
          title,
          style: AppTextStyle.displayXs(
            color: colors.onSurface,
            weight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        if (customSubtitle != null)
          customSubtitle!
        else
          Text(
            subtitle,
            style: AppTextStyle.textSm(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
