import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class ExploreActivityRafflePrizeChip extends StatelessWidget {
  const ExploreActivityRafflePrizeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyle.textMd(
          color: colorScheme.primary,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
