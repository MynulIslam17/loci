import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

class ExploreActivityDetailHero extends StatelessWidget {
  const ExploreActivityDetailHero({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.belowTitle,
    this.badges,
  });

  final String? imageUrl;
  final String title;
  final String description;
  final Widget? belowTitle;
  final Widget? badges;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomCachedImage(
            imageUrl: imageUrl,
            height: 200,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTextStyle.textMd(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        if (badges != null) ...[
          const SizedBox(height: 8),
          badges!,
        ],
        if (belowTitle != null) ...[
          const SizedBox(height: 8),
          belowTitle!,
        ],
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyle.textSm(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
