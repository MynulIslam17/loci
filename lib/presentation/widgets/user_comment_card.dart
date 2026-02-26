import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_text_style.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extention.dart';

class UserCommentCard extends StatelessWidget {
  final String userName;
  final String commentText;
  final String userImage;
  final String likeCount;
  final String replyCount;

  const UserCommentCard({
    super.key,
    required this.userName,
    required this.commentText,
    required this.userImage,
    required this.likeCount,
    required this.replyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. User Avatar (Positioned outside the bubble)
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(userImage),
            backgroundColor: context.colorScheme.outline.withOpacity(0.1),
          ),
          const SizedBox(width: 12),

          // 2. The Comment Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Adaptive color for light/dark mode
                color: context.colorScheme.onPrimaryContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and More Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w700,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Comment Body Text
                  Text(
                    commentText,
                    style: AppTextStyle.textSm(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Interaction Row (Like and Reply counts)
                  Row(
                    children: [
                      _CommentAction(
                        icon: Icons.favorite_border,
                        count: likeCount,
                      ),
                      const SizedBox(width: 20),
                      _CommentAction(
                        icon: Icons.chat_bubble_outline,
                        count: replyCount,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Internal Helper for the small Like/Reply icons
class _CommentAction extends StatelessWidget {
  final IconData icon;
  final String count;

  const _CommentAction({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.neutral400, // Soft grey color
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: AppTextStyle.textXs(
            weight: FontWeight.w600,
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }
}