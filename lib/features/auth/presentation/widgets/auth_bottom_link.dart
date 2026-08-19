import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_rich_text.dart';

/// Reusable footer link for switching between Login and Signup.
class AuthBottomLink extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onTap;

  const AuthBottomLink({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Center(
      child: CustomRichText(
        parts: [
          TextPart(
            text: promptText,
            style: AppTextStyle.textSm(
              color: colors.onSurface,
            ),
          ),
          TextPart(
            text: actionText,
            style: AppTextStyle.textSm(
              color: colors.primary,
              weight: FontWeight.w700,
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
          ),
        ],
      ),
    );
  }
}
