import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class ExploreActivityVisibilityRow extends StatelessWidget {
  const ExploreActivityVisibilityRow({
    super.key,
    required this.isPublic,
    required this.onChanged,
  });

  final bool isPublic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listing visibility',
                  style: AppTextStyle.textSm(
                    weight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPublic
                      ? 'Anyone can discover this activity'
                      : 'Only you can see this',
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isPublic,
            activeThumbColor: colorScheme.onPrimary,
            activeTrackColor: colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
