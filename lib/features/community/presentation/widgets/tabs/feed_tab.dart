import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
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

class _FeedTabState extends State<FeedTab> with AutomaticKeepAliveClientMixin {
  static const _tabType = AnnouncementType.question;

  @override
  bool get wantKeepAlive => true;
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

  void _dismissMentionUi() {
    FocusManager.instance.primaryFocus?.unfocus();
    _activeMentionPostId.value = null;
    _searchCtrl.reset();
  }

  void _onMentionChanged(String postId, String query) {
    _claimMentionSession(postId, resetIfSwitching: true);
    _searchCtrl.onSearchChanged(query);
  }

  void _onMentionFocusChanged(String postId, bool focused) {
    if (!focused) return;
    _claimMentionSession(postId, resetIfSwitching: true);
  }

  void _claimMentionSession(String postId, {required bool resetIfSwitching}) {
    final previous = _activeMentionPostId.value;
    if (resetIfSwitching && previous != null && previous != postId) {
      _searchCtrl.reset();
    }
    _activeMentionPostId.value = postId;
  }

  void _onMentionBusinessSelected(String postId, BrowseBusinessModel business) {
    _searchCtrl.reset();
  }

  // _onMentionSubmit handler
  Future<void> _onMentionSubmit(
    String postId,
    String text,
    String image,
  ) async {
    _dismissMentionUi();
    await widget.onMentionSubmit(postId, text, image);
    if (mounted) _dismissMentionUi();
  }
  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final annCtrl = Get.find<AnnouncementController>();
      annCtrl.revisionFor(_tabType).value;
      annCtrl.announcementMap.length;
      annCtrl.communityOwnerUserId.value;
      final announcements = annCtrl.announcementsFor(_tabType);
      final searchCtrl = _searchCtrl;
      searchCtrl.status.value;
      searchCtrl.businesses.length;
      searchCtrl.isPaginationLoading.value;
      final activeId = _activeMentionPostId.value;
      final me = _authController.userModelRx.value;
      final avatarRev = _authController.avatarRevision.value;
      final myAvatar = me?.avatar ?? '';

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
                key: ValueKey('feed-post-${announcement.id}'),
                viewModel: PostCardViewModel.from(
                  announcement,
                  communityOwnerUserId: annCtrl.communityOwnerUserId.value,
                ),
                onLikeTap: (postId) {
                  _dismissMentionUi();
                  widget.onLikeTap(postId);
                },
                onCommentTap: (postId) {
                  _dismissMentionUi();
                  widget.onCommentTap(postId);
                },
                onClickPoll: (_) {
                  _dismissMentionUi();
                  widget.onPollTap(announcement);
                },
                onMentionChanged: _onMentionChanged,
                onMentionSubmit: _onMentionSubmit,
                onMentionBusinessSelected: _onMentionBusinessSelected,
                onMentionFocusChanged: _onMentionFocusChanged,
                mentionSuggestions: isActive
                    ? List<BrowseBusinessModel>.from(searchCtrl.businesses)
                    : const [],
                isMentionLoading: isActive && searchCtrl.isLoading,
                mentionSearchDone: isActive && searchCtrl.searchDone,
                isMentionActive: isActive,
                mentionHasNextPage: isActive && searchCtrl.hasNextPage,
                mentionIsPaginationLoading:
                    isActive && searchCtrl.isPaginationLoading.value,
                onMentionLoadMore: isActive
                    ? () => searchCtrl.loadNextPage()
                    : null,
                currentUserImage: myAvatar,
                currentUserId: me?.id,
                avatarRevision: avatarRev,
              );
            },
          ),
        ],
      );
    });
  }
}
