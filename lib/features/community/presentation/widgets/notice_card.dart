import 'package:flutter/material.dart';
import 'package:loci/features/community/presentation/widgets/community_announcement_card_shell.dart';
import 'package:loci/shared/widgets/feed/expandable_text.dart';
import 'package:loci/shared/widgets/feed/post_interaction_bar.dart';
import 'package:loci/shared/widgets/feed/user_post_header.dart';

class CommunityNoticeCard extends StatelessWidget {
  final String profileImage;
  final String displayName;
  final bool isModerator;
  final String dateTime;
  final String noticeText;
  final String likes;
  final String comments;
  final bool isLiked;

  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const CommunityNoticeCard({
    super.key,
    required this.profileImage,
    required this.displayName,
    this.isModerator = false,
    required this.dateTime,
    required this.noticeText,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return CommunityAnnouncementCardShell(
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
          ExpandableText(text: noticeText, trimLines: 2),
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
