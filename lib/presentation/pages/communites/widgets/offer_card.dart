import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/common/post_comment_section.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../home/widgets/expandable_text.dart';
import '../../home/widgets/post_interaction_bar.dart';

class CommunityOfferCard extends StatelessWidget {
  final String profileImage;
  final String businessName;
  final String dateTime;
  final String description;
  final String couponImageUrl;
  final String likes;
  final String comments;

  final VoidCallback? onDownloadTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const CommunityOfferCard({
    super.key,
    required this.profileImage,
    required this.businessName,
    required this.dateTime,
    required this.description,
    required this.couponImageUrl,
    required this.likes,
    required this.comments,
    this.onDownloadTap,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Row(
              children: [
                CustomCachedImage(
                  width: 42,
                  height: 42,
                  imageUrl: profileImage,
                  isCircle: true,
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateTime,
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Optional menu icon (production feel)
                Icon(
                  Icons.more_vert,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ---------------- DESCRIPTION ----------------
            ExpandableText(
              text: description,
              trimLines: 2,
            ),

            const SizedBox(height: 12),

            // ---------------- IMAGE ----------------
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomCachedImage(
                      imageUrl: couponImageUrl,
                    ),
                  ),

                  // Download button overlay
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: InkWell(
                      onTap: onDownloadTap,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.download_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ---------------- INTERACTION ----------------
            PostInteractionBar(
              likes: likes,
              comments: comments,
              onLikeTap: onLikeTap,
              onCommentTap: onCommentTap,
            ),
          ],
        ),
      ),
    );
  }
}