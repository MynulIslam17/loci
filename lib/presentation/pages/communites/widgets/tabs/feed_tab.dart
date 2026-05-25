import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';
import 'package:loci/presentation/controllers/community/announcement_controller.dart';
import 'package:loci/presentation/controllers/community/search_business_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card_view_model.dart';

/// FeedTab owns:
///   - which card is currently being typed into (_activeMentionPostId)
///   - SearchBusinessController lifecycle
///
/// Everything else flows up to CommunityScreen via callbacks.
class FeedTab extends StatefulWidget {
  final void Function(String postId) onCommentTap;
  final void Function(AnnouncementModel announcement) onPollTap;
  final void Function(String postId) onLikeTap;
  final Future<void> Function(String postId, String text, String image) onMentionSubmit;


  const FeedTab({
    super.key,
    required this.onCommentTap,
    required this.onPollTap,
    required this.onLikeTap,
    required this.onMentionSubmit,
  });

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  late final SearchBusinessController _searchCtrl;
  String? _activeMentionPostId;
  final _authController = Get.find<AuthController>();

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

  // _onMentionSubmit handler
  Future<void> _onMentionSubmit(String postId, String text, String image) async {
    setState(() => _activeMentionPostId = null);
    _searchCtrl.reset();
    await widget.onMentionSubmit(postId, text, image);
  }
  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnnouncementController>(
      builder: (annCtrl) => GetBuilder<SearchBusinessController>(
        builder: (searchCtrl) => Column(
          children: [
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
                  isMentionLoading: isActive && searchCtrl.isLoading,
                  mentionSearchDone: isActive && searchCtrl.searchDone,
                  currentUserImage: _authController.userModel?.avatar ?? "",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}