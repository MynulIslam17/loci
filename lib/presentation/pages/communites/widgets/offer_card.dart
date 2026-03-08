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
  final String date;
  final String time;
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
    required this.date,
    required this.time,
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

    return Card(
      elevation: 1,
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage(profileImage),
                  backgroundColor: colorScheme.surfaceVariant,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "$date  $time",
                      style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            ExpandableText(
              text: description,
              trimLines: 1,
            ),
            const SizedBox(height: 12),

            // Coupon Container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.onSurface),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomCachedImage(
                      imageUrl: couponImageUrl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDownloadTap,
                    icon: Icon(Icons.file_download_outlined, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Footer Interaction (react / comment)
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