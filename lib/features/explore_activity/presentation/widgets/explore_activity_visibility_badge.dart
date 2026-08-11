import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class ExploreActivityVisibilityBadge extends StatelessWidget {
  const ExploreActivityVisibilityBadge({super.key, required this.isPublic});

  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPublic
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPublic ? 'Public' : 'Private',
        style: AppTextStyle.textXs(
          color: isPublic ? colorScheme.primary : colorScheme.onSurfaceVariant,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
