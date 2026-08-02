import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/recent_activity/presentation/widgets/activity_card_shell.dart';
import 'package:loci/shared/widgets/business_avatar.dart';

Widget buildBusinessActivityCard({
  required BuildContext context,
  required String businessName,
  required String category,
  required String lastVisited,
  required VoidCallback onDelete,
  required bool isDeleting,
  String? imageUrl,
}) {
  final colorScheme = context.colorScheme;
  final notVisited = lastVisited.toLowerCase().contains('not visited');

  return ActivityCardShell(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: BusinessAvatar(imageUrl: imageUrl, size: 50),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textSm(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ActivityCategoryChip(label: category),
                  ActivityMetaChip(
                    icon: notVisited
                        ? Icons.location_off_outlined
                        : Icons.history_rounded,
                    label: lastVisited,
                    iconColor: notVisited
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                    backgroundColor: notVisited
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.primaryContainer.withValues(alpha: 0.4),
                    foregroundColor: notVisited
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        isDeleting
            ? SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              )
            : Material(
                color: colorScheme.errorContainer.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.bookmark_remove_rounded,
                      size: 20,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
      ],
    ),
  );
}
