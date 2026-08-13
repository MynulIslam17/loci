import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';

class UserPostHeader extends StatelessWidget {
  final String fullName;
  final String date;
  final String category;
  final String imagePath;
  final bool isModerator;
  final String? imageCacheKey;

  const UserPostHeader({
    super.key,
    required this.fullName,
    required this.date,
    required this.category,
    required this.imagePath,
    this.isModerator = false,
    this.imageCacheKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CustomCachedImage(
          imageUrl: imagePath,
          cacheKey: imageCacheKey,
          width: 34,
          height: 34,
          isCircle: true,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w600,
                        color: theme.onSurface,
                      ),
                    ),
                  ),
                  if (isModerator) ...[
                    const SizedBox(width: 8),
                    _ModeratorTag(colorScheme: theme),
                  ],
                  if (category.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const Text(
                      "•",
                      style: TextStyle(color: AppColors.neutral300),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textXs(color: AppColors.primaryG500),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: AppTextStyle.textXs(color: theme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeratorTag extends StatelessWidget {
  const _ModeratorTag({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Moderator',
        style: AppTextStyle.textXs(
          weight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
