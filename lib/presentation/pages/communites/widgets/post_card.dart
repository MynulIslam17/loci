import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card_view_model.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../home/widgets/expandable_text.dart';
import '../../home/widgets/poll_bar.dart';
import '../../home/widgets/post_interaction_bar.dart';
import '../../home/widgets/user_post_header.dart';

/// Every action is bubbled up via callbacks.
class PostCardWidget extends StatefulWidget {
  final PostCardViewModel viewModel;

  // Core interactions
  final void Function(String postId)? onLikeTap;
  final void Function(String postId)? onCommentTap;
  final void Function(String postId)? onClickPoll;

  // Mention field — text changes & submit
  final void Function(String postId, String query)? onMentionChanged;
  final Future<void> Function(String postId, String text, String image)? onMentionSubmit;
  final void Function(String postId, BrowseBusinessModel business)? onMentionBusinessSelected;

  // Mention suggestions — fully controlled by parent
  final List<BrowseBusinessModel> mentionSuggestions;
  final bool isMentionLoading;
  final bool mentionSearchDone;

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
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  final TextEditingController _mentionController = TextEditingController();
  BrowseBusinessModel? _selectedBusiness; // ← tracks which business was picked
  bool _isSubmitting = false;

  @override
  void dispose() {
    _mentionController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (_selectedBusiness != null && value != _selectedBusiness!.name) {
      setState(() => _selectedBusiness = null);
    }
    widget.onMentionChanged?.call(widget.viewModel.postId, value);
  }

  void _onBusinessTapped(BrowseBusinessModel business) {
    _mentionController.text = business.name;
    _selectedBusiness = business; // ← store it
    widget.onMentionBusinessSelected?.call(widget.viewModel.postId, business);
  }

  Future<void> _submit() async {
    final text = _mentionController.text.trim();
    if (text.isEmpty || _isSubmitting || _selectedBusiness == null) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onMentionSubmit?.call(
        widget.viewModel.postId,
        text,
        _selectedBusiness?.logo ?? '',
      );
      _mentionController.clear();
      _selectedBusiness = null;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final colors = context.colorScheme;
    final showDropdown = widget.isMentionLoading ||
        widget.mentionSuggestions.isNotEmpty ||
        widget.mentionSearchDone;

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
            if (vm.pollOptions != null && vm.pollOptions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              InkWell(
                onTap: () => widget.onClickPoll?.call(vm.postId),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...vm.pollOptions!.take(2).map((opt) {
                      final percent = vm.totalVotes > 0
                          ? opt.voteCount / vm.totalVotes
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PollBar(
                          title: opt.text,
                          percent: percent,
                          percentage: opt.percentage,
                          imagePath: opt.image,
                          voters: opt.voters,
                        ),
                      );
                    }),
                    if (vm.pollOptions!.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'See all ${vm.pollOptions!.length} options',
                          style: AppTextStyle.textSm(
                            color: colors.primary,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Mention / business input (poll only) ─────────────────────────
            if (vm.isPoll) Row(
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
                    controller: _mentionController,
                    onChanged: _onTextChanged,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'Mention the business...',
                      hintStyle: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                      ),
                      border: const UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      suffixIcon: _isSubmitting
                          ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : IconButton(
                        icon: Icon(
                          Icons.send,
                          color: _selectedBusiness != null
                              ? null
                              : Colors.grey,
                        ),
                        onPressed: _selectedBusiness != null ? _submit : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Suggestion dropdown ──────────────────────────────────────────
            if (vm.isPoll && showDropdown) ...[
              const SizedBox(height: 4),
              _SuggestionDropdown(
                isLoading: widget.isMentionLoading,
                suggestions: widget.mentionSuggestions,
                colors: colors,
                onTap: _onBusinessTapped,
              ),
            ],

            const SizedBox(height: 20),

            // ── Like / comment bar ───────────────────────────────────────────
            PostInteractionBar(
              likes: vm.likes,
              comments: vm.comments,
              isLiked: vm.isLiked,
              onLikeTap: () => widget.onLikeTap?.call(vm.postId),
              onCommentTap: () => widget.onCommentTap?.call(vm.postId),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private suggestion dropdown — extracted for cleanliness
// ---------------------------------------------------------------------------
class _SuggestionDropdown extends StatelessWidget {
  final bool isLoading;
  final List<BrowseBusinessModel> suggestions;
  final ColorScheme colors;
  final void Function(BrowseBusinessModel) onTap;

  const _SuggestionDropdown({
    required this.isLoading,
    required this.suggestions,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline),
      ),
      child: isLoading
          ? const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      )
          : suggestions.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'No businesses found',
          style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
        ),
      )
          : ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: suggestions.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: colors.outline),
          itemBuilder: (context, index) {
            final business = suggestions[index];
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: colors.primaryContainer,
                backgroundImage: business.logo.isNotEmpty
                    ? NetworkImage(business.logo)
                    : null,
                child: business.logo.isEmpty
                    ? Text(
                  business.name.isNotEmpty
                      ? business.name[0].toUpperCase()
                      : '?',
                  style: AppTextStyle.textSm(
                    color: colors.onPrimaryContainer,
                  ),
                )
                    : null,
              ),
              title: Text(
                business.name,
                style: AppTextStyle.textSm(color: colors.onSurface),
              ),
              subtitle: Text(
                business.category,
                style:
                AppTextStyle.textXs(color: colors.onSurfaceVariant),
              ),
              onTap: () => onTap(business),
            );
          },
        ),
      ),
    );
  }
}