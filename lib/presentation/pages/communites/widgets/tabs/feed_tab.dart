import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/presentation/controllers/community/announcement_controller.dart';
import 'package:loci/presentation/controllers/community/search_business_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card_view_model.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';

/// FeedTab owns:
///   - which card is currently being typed into (_activeMentionPostId)
///   - SearchBusinessController lifecycle
///
/// Everything else flows up to CommunityScreen via callbacks.
class FeedTab extends StatefulWidget {
  final void Function(String postId) onCommentTap;
  final void Function(AnnouncementModel announcement) onPollTap;
  final void Function(String postId) onLikeTap;
  final Future<void> Function(String text, String category) onSubmit;
  final Future<void> Function(String postId, String text) onMentionSubmit;

  const FeedTab({
    super.key,
    required this.onCommentTap,
    required this.onPollTap,
    required this.onLikeTap,
    required this.onSubmit,
    required this.onMentionSubmit,
  });

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  late final SearchBusinessController _searchCtrl;
  String? _activeMentionPostId;

  @override
  void initState() {
    super.initState();
    _searchCtrl = Get.put(SearchBusinessController());
  }

  @override
  void dispose() {
    Get.delete<SearchBusinessController>();
    super.dispose();
  }

  // ── Mention callbacks ────────────────────────────────────────────────────

  void _onMentionChanged(String postId, String query) {
    setState(() => _activeMentionPostId = postId);
    _searchCtrl.onSearchChanged(query);
  }

  void _onMentionBusinessSelected(String postId, BrowseBusinessModel business) {
    // Parent already filled the text field in PostCardWidget.
    // Here we just clear search state.
    setState(() => _activeMentionPostId = null);
    _searchCtrl.reset();
  }

  Future<void> _onMentionSubmit(String postId, String text) async {
    setState(() => _activeMentionPostId = null);
    _searchCtrl.reset();
    await widget.onMentionSubmit(postId, text);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnnouncementController>(
      builder: (annCtrl) => GetBuilder<SearchBusinessController>(
        builder: (searchCtrl) => Column(
          children: [
            // ── Post question input ────────────────────────────────────────
            PostInputField(
              categories:
              BusinessCategory.values.map((e) => e.label).toList(),
              initialCategory: BusinessCategory.foodie.label,
              onSubmit: widget.onSubmit,
              hintText: 'Post a question...',
            ),

            const SizedBox(height: 16),

            // ── Post list ─────────────────────────────────────────────────
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: annCtrl.announcements.length,
              itemBuilder: (context, index) {
                final announcement = annCtrl.announcements[index];
                final isActive =
                    _activeMentionPostId == announcement.id;

                return PostCardWidget(
                  viewModel: PostCardViewModel.from(announcement),
                  onLikeTap: widget.onLikeTap,
                  onCommentTap: widget.onCommentTap,
                  onClickPoll: (_) => widget.onPollTap(announcement),
                  onMentionChanged: _onMentionChanged,
                  onMentionSubmit: _onMentionSubmit,
                  onMentionBusinessSelected: _onMentionBusinessSelected,
                  // Only the active card gets live suggestions
                  mentionSuggestions:
                  isActive ? searchCtrl.businesses : const [],
                  isMentionLoading:
                  isActive && searchCtrl.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}