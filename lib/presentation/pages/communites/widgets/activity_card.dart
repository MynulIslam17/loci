import 'package:flutter/material.dart';
import 'package:loci/presentation/pages/home/widgets/expandable_text.dart';
import 'package:loci/presentation/pages/home/widgets/post_interaction_bar.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';

/// Card for community activity with header, description, activity content, and interaction bar.
class CommunityActivityCard extends StatelessWidget {
  final String profileImage;
  final String businessName;
  final String date;
  final String time;
  final String description;
  final String likes;
  final String comments;

  /// Widget representing the activity (RouteCard, PostCard, etc.)
  final Widget activityContent;

  /// Callbacks for like/comment taps
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const CommunityActivityCard({
    super.key,
    required this.profileImage,
    required this.businessName,
    required this.date,
    required this.time,
    required this.description,
    required this.likes,
    required this.comments,
    required this.activityContent,
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
            // Header: Profile + Name + Timestamp
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
                      "$date  $time",
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description text
            ExpandableText(
              text: description,
              trimLines: 2,
            ),
            const SizedBox(height: 16),

            // Activity content (RouteCard, PostCard, etc.)
            activityContent,
            const SizedBox(height: 18),

            // Like / Comment interaction
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