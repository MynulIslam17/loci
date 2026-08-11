import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/form_labels.dart';

/// Card-style section used on create, edit, and detail screens.
class ExploreActivitySection extends StatelessWidget {
  const ExploreActivitySection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.highlightTitle = false,
    this.optional = false,
  });

  final String? title;
  final String? subtitle;
  final bool highlightTitle;
  final bool optional;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            if (highlightTitle)
              FormSectionLabel(label: title!, optional: optional)
            else
              Text(
                title!,
                style: AppTextStyle.textMd(
                  weight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
