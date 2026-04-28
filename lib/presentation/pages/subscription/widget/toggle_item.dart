import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/constants/app_text_style.dart';

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
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Text(
            title,
            style: AppTextStyle.textSm(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}