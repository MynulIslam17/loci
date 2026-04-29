import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

import '../../../widgets/custom_image_container.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String ? businessName;
  final String reviewText;
  final String imageUrl;
  final double rating;
  final String? time;
  final VoidCallback? onMenuTap;

  const ReviewCard({
    super.key,
    required this.name,
     this.businessName,
    required this.reviewText,
    required this.imageUrl,
    this.rating = 5,
    this.time,
    this.onMenuTap,
  });

  List<Widget> _buildStars(double rating) {
    return List.generate(5, (index) {
      if (rating >= index + 1) {
        return const Icon(Icons.star, color: Colors.orangeAccent, size: 14);
      } else if (rating > index && rating < index + 1) {
        return const Icon(Icons.star_half, color: Colors.orangeAccent, size: 14);
      } else {
        return const Icon(Icons.star_border, color: Colors.orangeAccent, size: 14);
      }
    });
  }

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

                /// --- Name & Business + Time ---
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
                      ///--if business name exists
                      if(businessName!=null)
                      Text(
                        businessName!,
                        style: AppTextStyle.textXs(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),

                      /// TIME (only if exists)
                      if (time != null)
                        Text(
                          time!,
                          style: AppTextStyle.textXs(
                            color: scheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// --- Rating & Menu ---
                Row(
                  children: [
                    ..._buildStars(rating),
                    const SizedBox(width: 4),
                    if (onMenuTap != null)
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