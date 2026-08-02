import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_manage_buttons.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// Shared layout for event / route / raffle cards on the explore tabs.
class ExploreActivityListCard extends StatelessWidget {
  const ExploreActivityListCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.meta,
    required this.onEdit,
    required this.onView,
    this.editLabel,
    this.viewLabel,
    this.titleTrailing,
    this.highlight,
    this.organizerLine,
    this.contentPadding = const EdgeInsets.all(12),
  });

  final String imageUrl;
  final String title;
  final String description;
  final List<Widget> meta;
  final Widget? titleTrailing;
  final Widget? highlight;
  final String? organizerLine;
  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final String? editLabel;
  final String? viewLabel;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            imageUrl: imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            customBorderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ?titleTrailing,
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (highlight != null) ...[
                  const SizedBox(height: 12),
                  highlight!,
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < meta.length; i++) ...[
                        meta[i],
                        if (i < meta.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ],
                if (organizerLine != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    organizerLine!,
                    style: AppTextStyle.textXs(
                      weight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ExploreActivityManageButtons(
                  onEdit: onEdit,
                  onView: onView,
                  editLabel: editLabel ?? 'Edit Info',
                  viewLabel: viewLabel ?? 'View Details',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
