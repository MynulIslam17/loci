import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class ExploreActivityQrButton extends StatelessWidget {
  const ExploreActivityQrButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.qr_code_2_outlined,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return CustomButton(
      backgroundColor: colorScheme.primary,
      textColor: colorScheme.onPrimary,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.onPrimary, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyle.textMd(
              color: colorScheme.onPrimary,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
