import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/feed/expandable_text.dart';
import 'package:loci/shared/widgets/feed/post_interaction_bar.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Card for community activity with header, description, activity content, and interaction bar.
class CommunityActivityCard extends StatelessWidget {
  final String profileImage;
  final String businessName;
  final String dateTime;
  final String description;
  final String likes;
  final String comments;
  final bool isLiked;
  final Widget? activityContent;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const CommunityActivityCard({
    super.key,
    required this.profileImage,
    required this.businessName,
    required this.dateTime,
    required this.description,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.activityContent,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 1,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(profileImage),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: AppTextStyle.textSm(weight: FontWeight.bold),
                    ),
                    Text(
                      dateTime,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            ExpandableText(text: description, trimLines: 2),

            if (activityContent != null) ...[
              const SizedBox(height: 16),
              activityContent!,
            ],

            const SizedBox(height: 18),

            // Interaction bar
            PostInteractionBar(
              likes: likes,
              comments: comments,
              isLiked: isLiked,
              onLikeTap: onLikeTap,
              onCommentTap: onCommentTap,
            ),
          ],
        ),
      ),
    );
  }
}
