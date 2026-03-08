import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

import '../../../widgets/custom_image_container.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String businessName;
  final String reviewText;
  final String imageUrl;
  final int rating;
  final VoidCallback? onMenuTap;

  const ReviewCard({
    super.key,
    required this.name,
    required this.businessName,
    required this.reviewText,
    required this.imageUrl,
    this.rating = 5,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Card(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header Row ---
            Row(
              children: [

                CustomCachedImage(
                  height: 50,
                  width: 50,
                  imageUrl: imageUrl,
                  isCircle: true,
                ),
                const SizedBox(width: 12),

                /// --- Name & Business ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        businessName,
                        style: AppTextStyle.textXs(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// --- Rating & Menu ---
                Row(
                  children: [
                    ...List.generate(
                      rating,
                          (i) => const Icon(
                        Icons.star,
                        color: Colors.orangeAccent,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onMenuTap,
                      icon: Icon(
                        Icons.more_horiz,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// --- Review Text ---
            Text(
              reviewText,
              style: AppTextStyle.textXs(color: scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}