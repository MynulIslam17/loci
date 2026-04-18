import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/theme/app_colors.dart';

import 'custom_image_container.dart';


class TaskCard extends StatelessWidget {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final VoidCallback? onRemove;

  const TaskCard({
    super.key,
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(

      key: ValueKey(id),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            /// Remove Button
            if (onRemove != null)
              InkWell(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.base50,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            /// Logo
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
              child: CustomCachedImage(
                width: 50,
                height: 50,
                isCircle: true,
                imageUrl: imageUrl,
              ),
            ),

            const SizedBox(width: 12),

            /// Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}