import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:loci/features/recent_activity/presentation/widgets/activity_card_shell.dart';

Widget buildQuestionActivityCard({
  required BuildContext context,
  required String name,
  required String question,
  required int likeCount,
  required int commentCount,
  String? imageUrl,
  String? category,
  String? date,
}) {
  final colorScheme = context.colorScheme;

  return ActivityCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatAvatar(name: name, avatarUrl: imageUrl, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if ((category ?? '').isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ActivityCategoryChip(label: category!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question,
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            ActivityMetaChip(
              icon: Icons.favorite_rounded,
              label: '$likeCount',
              iconColor: colorScheme.error,
              backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.35),
              foregroundColor: colorScheme.error,
            ),
            const SizedBox(width: 8),
            ActivityMetaChip(
              icon: Icons.chat_bubble_rounded,
              label: '$commentCount',
              iconColor: colorScheme.primary,
              backgroundColor:
                  colorScheme.primaryContainer.withValues(alpha: 0.45),
              foregroundColor: colorScheme.primary,
            ),
            const Spacer(),
            if ((date ?? '').isNotEmpty)
              ActivityMetaChip(
                icon: Icons.schedule_rounded,
                label: date!,
              ),
          ],
        ),
      ],
    ),
  );
}
