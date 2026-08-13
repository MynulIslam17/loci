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
  final bool isMentionActive;
  final void Function(String postId, bool focused)? onMentionFocusChanged;

  // Used to highlight which poll bar this user voted on, and to live-update
  // "my" post avatars after a profile picture change.
  final String? currentUserId;
  final int avatarRevision;

  const PostCardWidget({
    super.key,
    required this.viewModel,
    this.onLikeTap,
    this.onCommentTap,
    this.onClickPoll,
    this.onMentionChanged,
    this.onMentionSubmit,
    this.onMentionBusinessSelected,
    this.onMentionFocusChanged,
    this.mentionSuggestions = const [],
    this.isMentionLoading = false,
    this.mentionSearchDone = false,
    this.isMentionActive = false,
    required this.currentUserImage,
    this.currentUserId,
    this.avatarRevision = 0,
  });

  bool get _hasPollOptions =>
      viewModel.pollOptions != null && viewModel.pollOptions!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final colors = context.colorScheme;
    final headerImage = vm.resolvedUserImage(
      currentUserId: currentUserId,
      currentUserImage: currentUserImage,
    );
    final isMine = currentUserId != null &&
        currentUserId!.isNotEmpty &&
        vm.authorId == currentUserId;
    final headerCacheKey = isMine && headerImage.isNotEmpty
        ? '$headerImage-$avatarRevision'
        : null;

    return Card(
      color: colors.surfaceContainer,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserPostHeader(
              fullName: vm.userName,
              date: vm.date,
              category: vm.category,
              imagePath: headerImage,
              imageCacheKey: headerCacheKey,
              isModerator: vm.isModerator,
            ),
            const SizedBox(height: 8),
            ExpandableText(text: vm.text, trimLines: 2),
            if (_hasPollOptions) ...[
              const SizedBox(height: 8),
              PollPreview(
                viewModel: vm,
                currentUserId: currentUserId,
                onTap: () => onClickPoll?.call(vm.postId),
              ),
            ],
            if (vm.isPoll) ...[
              const SizedBox(height: 8),
              PollMentionField(
                key: ValueKey('mention-${vm.postId}'),
                postId: vm.postId,
                currentUserImage: currentUserImage,
                avatarRevision: avatarRevision,
                isActive: isMentionActive,
                suggestions: isMentionActive ? mentionSuggestions : const [],
                isLoading: isMentionActive && isMentionLoading,
                searchDone: isMentionActive && mentionSearchDone,
                onChanged: onMentionChanged,
                onBusinessSelected: onMentionBusinessSelected,
                onSubmit: onMentionSubmit,
                onFocusChanged: onMentionFocusChanged,
              ),
            ],
            const SizedBox(height: 6),
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
