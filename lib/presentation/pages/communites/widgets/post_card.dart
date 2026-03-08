import 'package:flutter/material.dart';
import '../../../../data/poll.dart';
import '../../../../data/post_model.dart';
import '../../../widgets/common/post_comment_section.dart';
import '../../home/widgets/expandable_text.dart';
import '../../home/widgets/post_interaction_bar.dart';
import '../../home/widgets/post_poll_section.dart';
import '../../home/widgets/user_post_header.dart';

class PostCardWidget extends StatelessWidget {
  final PostModel post;
  final List<PollOption>? polls;
  final List<CommentData>? comments;
  final String? expandedPostId;

  // Callbacks controlled by parent
  final void Function(String postId)? onExpandToggle;
  final void Function(String postId)? onLikeTap;
  final void Function(String postId)? onCommentTap;

  const PostCardWidget({
    super.key,
    required this.post,
    this.polls,
    this.comments,
    required this.expandedPostId,
    this.onExpandToggle,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = expandedPostId == post.id;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            UserPostHeader(
              fullName: post.userName,
              date: post.date,
              category: post.category,
              imagePath: post.userImage,
            ),
            const SizedBox(height: 20),

            // Post content
            ExpandableText(
              text: post.text,
              trimLines: 2,
            ),

            // Polls section (optional)
            if (polls != null && polls!.isNotEmpty) ...[
              const SizedBox(height: 20),
              PostPollSection(options: polls!),
            ],

            const SizedBox(height: 20),

            // Interaction bar
            PostInteractionBar(
              likes: post.likes,
              comments: post.commentsCount,
              onLikeTap: () => onLikeTap?.call(post.id),
              onCommentTap: () {
                onCommentTap?.call(post.id);
                onExpandToggle?.call(post.id);
              },
            ),

            // Expanded comments
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded && comments != null
                  ? Column(
                children: [
                  const SizedBox(height: 8),
                  Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  PostCommentSection(
                    currentUserImage: 'assets/images/user3.png',
                    comments: comments!,
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}