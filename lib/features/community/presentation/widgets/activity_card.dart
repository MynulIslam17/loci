import 'package:flutter/material.dart';
import 'package:loci/features/community/presentation/widgets/community_announcement_card_shell.dart';
import 'package:loci/shared/widgets/feed/expandable_text.dart';
import 'package:loci/shared/widgets/feed/post_interaction_bar.dart';
import 'package:loci/shared/widgets/feed/user_post_header.dart';

/// Card for community activity with header, description, activity content, and interaction bar.
class CommunityActivityCard extends StatelessWidget {
  final String profileImage;
  final String displayName;
  final bool isModerator;
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
    required this.displayName,
    this.isModerator = false,
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
    return CommunityAnnouncementCardShell(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserPostHeader(
            fullName: displayName,
            date: dateTime,
            category: '',
            imagePath: profileImage,
            isModerator: isModerator,
          ),
          const SizedBox(height: 12),
          ExpandableText(text: description, trimLines: 2),
          if (activityContent != null) ...[
            const SizedBox(height: 16),
            activityContent!,
          ],
          const SizedBox(height: 14),
          PostInteractionBar(
            likes: likes,
            comments: comments,
            isLiked: isLiked,
            onLikeTap: onLikeTap,
            onCommentTap: onCommentTap,
          ),
        ],
      ),
    );
  }
}
