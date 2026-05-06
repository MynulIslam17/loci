import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/presentation/pages/home/widgets/expandable_text.dart';
import 'package:loci/presentation/pages/home/widgets/post_interaction_bar.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../widgets/custom_image_container.dart';

class CommunityNoticeCard extends StatelessWidget {
  final String profileImage;
  final String businessName;
  final String dateTime;
  final String noticeText;
  final String likes;
  final String comments;

  /// Callbacks for like/comment taps
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const CommunityNoticeCard({
    super.key,
    required this.profileImage,
    required this.businessName,
    required this.dateTime,
    required this.noticeText,
    required this.likes,
    required this.comments,
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
            // Header: Profile, Name, and Timestamp
            Row(
              children: [
                CustomCachedImage(
                  width: 42,
                  height: 42,
                  imageUrl: profileImage,
                  isCircle: true,
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
            const SizedBox(height: 16),

            // Notice Content
            ExpandableText(text: noticeText, trimLines: 2),
            const SizedBox(height: 20),

            // Interaction Bar with onTap callbacks
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