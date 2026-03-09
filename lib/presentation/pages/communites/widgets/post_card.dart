import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../data/poll.dart';
import '../../../../data/post_model.dart';
import '../../../widgets/common/post_comment_section.dart';
import '../../home/widgets/expandable_text.dart';
import '../../home/widgets/post_interaction_bar.dart';
import '../../home/widgets/post_poll_section.dart';
import '../../home/widgets/user_post_header.dart';

class PostCardWidget extends StatefulWidget {
  final PostModel post;
  final List<PollOption>? polls;
  final List<CommentData>? comments;
  final String? expandedPostId;

  // Callbacks controlled by parent
  final void Function(String postId)? onExpandToggle;
  final void Function(String postId)? onLikeTap;
  final void Function(String postId)? onCommentTap;
  final void Function(String postId)? onClickPoll;

  /// Optional controller from parent
  final TextEditingController? controller; // 👈 optional from parent

  /// Parent handles text submit
  final void Function(String postId, String value)? onSubmit;
  final void Function(String postId, String value)? onChanged;

  const PostCardWidget({
    super.key,
    required this.post,
    this.polls,
    this.comments,
    required this.expandedPostId,
    this.onExpandToggle,
    this.onLikeTap,
    this.onCommentTap,
    this.onClickPoll,
    this.controller, // 👈 optional
    this.onSubmit,
    this.onChanged,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 👇 use parent's or create own
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // 👇 only dispose if we created it ourselves
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.expandedPostId == widget.post.id;

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
              fullName: widget.post.userName,
              date: widget.post.date,
              category: widget.post.category,
              imagePath: widget.post.userImage,
            ),
            const SizedBox(height: 20),

            // Post content
            ExpandableText(text: widget.post.text, trimLines: 2),

            // Polls section (with clickable)
            if (widget.polls != null && widget.polls!.isNotEmpty) ...[
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  widget.onClickPoll?.call(widget.post.id);
                },
                child: PostPollSection(options: widget.polls!),
              ),
            ],

            const SizedBox(height: 20),

            // Text input row
            Row(
              children: [
                CustomCachedImage(
                  width: 40,
                  height: 40,
                  isCircle: true,
                  imageUrl: "assets/images/logo.png",
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller, // 👈 use _controller
                    onChanged: (value) => widget.onChanged?.call(widget.post.id, value),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        widget.onSubmit?.call(widget.post.id, value.trim());
                        _controller.clear(); // 👈 use _controller
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Mention the business...',
                      hintStyle: AppTextStyle.textXs(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      border: const UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            widget.onSubmit?.call(widget.post.id, _controller.text.trim());
                            _controller.clear(); // 👈 use _controller
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Interaction bar
            PostInteractionBar(
              likes: widget.post.likes,
              comments: widget.post.commentsCount,
              onLikeTap: () => widget.onLikeTap?.call(widget.post.id),
              onCommentTap: () {
                widget.onCommentTap?.call(widget.post.id);
                widget.onExpandToggle?.call(widget.post.id);
              },
            ),

            // Expanded comments
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded && widget.comments != null
                  ? Column(
                children: [
                  const SizedBox(height: 8),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  PostCommentSection(
                    currentUserImage: 'assets/images/user3.png',
                    comments: widget.comments!,
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