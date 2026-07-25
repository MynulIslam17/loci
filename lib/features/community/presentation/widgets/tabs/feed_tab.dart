import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/search_business_controller.dart';
import 'package:loci/shared/widgets/feed/post_card.dart';
import 'package:loci/shared/models/post_card_view_model.dart';

/// FeedTab owns:
///   - which card is currently being typed into (_activeMentionPostId)
///   - SearchBusinessController lifecycle
///
/// Everything else flows up to CommunityScreen via callbacks.
class FeedTab extends StatefulWidget {
  final void Function(String postId) onCommentTap;
  final void Function(AnnouncementModel announcement) onPollTap;
  final void Function(String postId) onLikeTap;
  final Future<void> Function(String postId, String text, String image)
  onMentionSubmit;

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
  final _activeMentionPostId = RxnString();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _searchCtrl = Get.put(
      SearchBusinessController(Get.find<CommunityService>()),
    );
  }

  @override
  void dispose() {
    Get.delete<SearchBusinessController>();
    super.dispose();
  }

  // ── Mention callbacks ────────────────────────────────────────────────────

  void _onMentionChanged(String postId, String query) {
    _activeMentionPostId.value = postId;
    _searchCtrl.onSearchChanged(query);
  }

  void _onMentionBusinessSelected(String postId, BrowseBusinessModel business) {
    // Parent already filled the text field in PostCardWidget.
    // Here we just clear search state.
    _activeMentionPostId.value = null;
    _searchCtrl.reset();
  }

  // _onMentionSubmit handler
  Future<void> _onMentionSubmit(
    String postId,
    String text,
    String image,
  ) async {
    _activeMentionPostId.value = null;
    _searchCtrl.reset();
    await widget.onMentionSubmit(postId, text, image);
  }
  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final annCtrl = Get.find<AnnouncementController>();
      final searchCtrl = _searchCtrl;
      // Subscribe to announcement map mutations (likes, votes, etc.).
      final announcements = annCtrl.announcements;
      annCtrl.announcementMap.length;
      // Subscribe to search status / results and active mention card.
      searchCtrl.status.value;
      searchCtrl.businesses.length;
      final activeId = _activeMentionPostId.value;

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final isActive = activeId == announcement.id;

              return PostCardWidget(
                viewModel: PostCardViewModel.from(announcement),
                onLikeTap: widget.onLikeTap,
                onCommentTap: widget.onCommentTap,
                onClickPoll: (_) => widget.onPollTap(announcement),
                onMentionChanged: _onMentionChanged,
                onMentionSubmit: _onMentionSubmit,
                onMentionBusinessSelected: _onMentionBusinessSelected,
                // Only the active card gets live suggestions
                mentionSuggestions: isActive
                    ? searchCtrl.businesses.toList()
                    : const [],
                isMentionLoading: isActive && searchCtrl.isLoading,
                mentionSearchDone: isActive && searchCtrl.searchDone,
                currentUserImage: _authController.userModel?.avatar ?? "",
              );
            },
          ),
        ],
      );
    });
  }
}
