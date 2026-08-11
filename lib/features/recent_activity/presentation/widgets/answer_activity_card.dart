import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/recent_activity/presentation/widgets/activity_card_shell.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

Widget buildAnswerActivityCard({
  required BuildContext context,
  required String question,
  required String answer,
  required String timestamp,
  String? imageUrl,
}) {
  final colorScheme = context.colorScheme;

  return ActivityCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ActivityCategoryChip(label: 'Your answer'),
            const Spacer(),
            ActivityMetaChip(
              icon: Icons.schedule_rounded,
              label: timestamp,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedImage(
              imageUrl: imageUrl,
              width: 36,
              height: 36,
              isCircle: true,
              fallbackIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On',
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    question,
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 18,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answer,
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w500,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
