import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/shared/models/post_card_view_model.dart';
import 'package:loci/shared/widgets/feed/expandable_text.dart';
import 'package:loci/shared/widgets/feed/poll_mention_field.dart';
import 'package:loci/shared/widgets/feed/poll_preview.dart';
import 'package:loci/shared/widgets/feed/post_interaction_bar.dart';
import 'package:loci/shared/widgets/feed/user_post_header.dart';

/// A feed post card (announcement or poll). Pure presentation: every action is
/// bubbled up via callbacks, and the poll preview / mention input are delegated
/// to [PollPreview] and [PollMentionField].
class PostCardWidget extends StatelessWidget {
  final PostCardViewModel viewModel;
  final String currentUserImage;

  // Core interactions
  final void Function(String postId)? onLikeTap;
  final void Function(String postId)? onCommentTap;
  final void Function(String postId)? onClickPoll;

  // Mention field — text changes & submit
  final void Function(String postId, String query)? onMentionChanged;
  final Future<void> Function(String postId, String text, String image)?
  onMentionSubmit;
  final void Function(String postId, BrowseBusinessModel business)?
  onMentionBusinessSelected;

  // Mention suggestions — fully controlled by parent
  final List<BrowseBusinessModel> mentionSuggestions;
  final bool isMentionLoading;
  final bool mentionSearchDone;

  // Used to highlight which poll bar this user voted on
  final String? currentUserId;

  const PostCardWidget({
    super.key,
    required this.viewModel,
    this.onLikeTap,
    this.onCommentTap,
    this.onClickPoll,
    this.onMentionChanged,
    this.onMentionSubmit,
    this.onMentionBusinessSelected,
    this.mentionSuggestions = const [],
    this.isMentionLoading = false,
    this.mentionSearchDone = false,
    required this.currentUserImage,
    this.currentUserId,
  });

  bool get _hasPollOptions =>
      viewModel.pollOptions != null && viewModel.pollOptions!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainer,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            UserPostHeader(
              fullName: vm.userName,
              date: vm.date,
              category: vm.category,
              imagePath: vm.userImage,
            ),
            const SizedBox(height: 20),

            // ── Post text ───────────────────────────────────────────────────
            ExpandableText(text: vm.text, trimLines: 2),

            // ── Poll options preview ─────────────────────────────────────────
            if (_hasPollOptions) ...[
              const SizedBox(height: 20),
              PollPreview(
                viewModel: vm,
                currentUserId: currentUserId,
                onTap: () => onClickPoll?.call(vm.postId),
              ),
            ],

            const SizedBox(height: 20),

            // ── Mention / business input (poll only) ─────────────────────────
            if (vm.isPoll)
              PollMentionField(
                postId: vm.postId,
                currentUserImage: currentUserImage,
                suggestions: mentionSuggestions,
                isLoading: isMentionLoading,
                searchDone: mentionSearchDone,
                onChanged: onMentionChanged,
                onBusinessSelected: onMentionBusinessSelected,
                onSubmit: onMentionSubmit,
              ),

            const SizedBox(height: 20),

            // ── Like / comment bar ───────────────────────────────────────────
            PostInteractionBar(
              likes: vm.likes,
              comments: vm.comments,
              isLiked: vm.isLiked,
              onLikeTap: () => onLikeTap?.call(vm.postId),
              onCommentTap: () => onCommentTap?.call(vm.postId),
            ),
          ],
        ),
      ),
    );
  }
}
