import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Displays API [status] values such as `draft`, `published`, `active`.
class ExploreActivityStatusBadge extends StatelessWidget {
  const ExploreActivityStatusBadge({super.key, required this.status});

  final String status;

  static String labelFor(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return 'Unknown';

    return value
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final normalized = status.trim().toLowerCase();
    final isDraft = normalized == 'draft';

    final Color background;
    final Color foreground;
    if (isDraft) {
      background = colorScheme.tertiary.withValues(alpha: 0.12);
      foreground = colorScheme.tertiary;
    } else if (normalized == 'published' || normalized == 'active') {
      background = colorScheme.primary.withValues(alpha: 0.1);
      foreground = colorScheme.primary;
    } else {
      background = colorScheme.outline.withValues(alpha: 0.1);
      foreground = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labelFor(status),
        style: AppTextStyle.textXs(
          color: foreground,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
