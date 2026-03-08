import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extention.dart';

/// Comment Card used for both current user and other users
class UserCommentCard extends StatelessWidget {
  final String userName;
  final String commentText;
  final String userImage;
  final String likeCount;
  final String replyCount;
  final bool isCurrentUser;

  /// Callbacks for dropdown actions
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onReply;

  const UserCommentCard({
    super.key,
    required this.userName,
    required this.commentText,
    required this.userImage,
    required this.likeCount,
    required this.replyCount,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ User Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(userImage),
            backgroundColor: context.colorScheme.outline.withOpacity(0.1),
          ),
          const SizedBox(width: 12),

          // 2️⃣ Comment Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
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
                  // Name + 3-dots menu
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

                      // Dropdown menu for comment actions
                      _CommentMenu(
                        isCurrentUser: isCurrentUser,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onReport: onReport,
                        onReply: onReply,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Comment Text
                  Text(
                    commentText,
                    style: AppTextStyle.textSm(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Interaction Row (Like / Reply)
                  Row(
                    children: [
                      _CommentAction(icon: Icons.favorite_border, count: likeCount),
                      const SizedBox(width: 20),
                      _CommentAction(icon: Icons.chat_bubble_outline, count: replyCount),
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

/// Small icon + count widget
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
          color: AppColors.neutral400,
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

/// Dropdown menu for comment actions
class _CommentMenu extends StatelessWidget {
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onReply;

  const _CommentMenu({
    required this.isCurrentUser,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, size: 18),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();// executes the parent callback
            break;
          case 'delete':
            onDelete?.call();
            break;
          case 'report':
            onReport?.call();
            break;
          case 'reply':
            onReply?.call();
            break;
        }
      },
      itemBuilder: (context) {
        if (isCurrentUser) {
          return [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
            const PopupMenuItem(value: 'report', child: Text('Report')),
          ];
        } else {
          return [
            const PopupMenuItem(value: 'reply', child: Text('Reply')),
            const PopupMenuItem(value: 'report', child: Text('Report')),
          ];
        }
      },
    );
  }
}