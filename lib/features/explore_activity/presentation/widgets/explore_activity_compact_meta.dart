import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Small icon + label row for activity list cards.
class ExploreActivityCompactMeta extends StatelessWidget {
  const ExploreActivityCompactMeta({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
