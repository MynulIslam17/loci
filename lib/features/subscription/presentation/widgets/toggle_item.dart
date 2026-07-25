import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/constants/app_text_style.dart';

/// A single tappable label in the billing toggle. It paints no background of
/// its own — the sliding highlight pill lives behind it in [BillingToggleSection]
/// — so switching tabs never blends two filled backgrounds.
class ToggleItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ToggleItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: AppTextStyle.textSm(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}
