import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';

class CommunityCard extends StatelessWidget {
  final String title;
  final String category;
  final String members;
  final String communityLogo;
  final String description;
  final VoidCallback communityOnTap;

  const CommunityCard({
    required this.title,
    required this.category,
    required this.members,
    required this.description,
    required this.communityLogo,
    required this.communityOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      elevation: 1,

      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: communityOnTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Community Avatar

                    CustomCachedImage(
                      width: 50,
                      height: 50,
                      isCircle: true,
                      imageUrl: communityLogo,
                    ),


                    const SizedBox(width: 12),

                    // Title and Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyle.textMd(weight: FontWeight.bold),
                          ),
                          Text(
                            category,
                            style: AppTextStyle.textSm(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Member Count
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          members,
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurfaceVariant,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}