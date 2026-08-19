import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Styled divider with label for social sign-in sections.
class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    this.text = 'Or login with',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppTextStyle.textXs(
              color: colors.onSurfaceVariant,
              weight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
