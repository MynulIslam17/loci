import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/search_business_controller.dart';
import 'package:loci/shared/widgets/feed/post_card.dart';
import 'package:loci/shared/models/post_card_view_model.dart';

/// Community feed cards — same [PostCardWidget] UX as home (mention search,
/// poll preview / vote sheet, likes, comments).
///
/// Owns:
///   - which card is currently being typed into ([_activeMentionPostId])
///   - [SearchBusinessController] lifecycle (tagged `community_feed`)
class FeedTab extends StatefulWidget {
  final void Function(String postId) onCommentTap;
  final void Function(String postId) onPollTap;
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
      tag: 'community_feed',
    );
  }

  @override
  void dispose() {
    Get.delete<SearchBusinessController>(tag: 'community_feed');
    super.dispose();
  }

  // ── Mention callbacks (mirror home_screen) ───────────────────────────────

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
    // Unfocus on the same card must NOT clear results (scroll/tap suggestions).
    // Focusing a *different* card switches the session and drops old results.
    if (!focused) return;
    _claimMentionSession(postId, resetIfSwitching: true);
  }

  /// Exactly one poll card owns mention search at a time.
  void _claimMentionSession(String postId, {required bool resetIfSwitching}) {
    final previous = _activeMentionPostId.value;
    if (resetIfSwitching && previous != null && previous != postId) {
      _searchCtrl.reset();
    }
    _activeMentionPostId.value = postId;
  }

  void _onMentionBusinessSelected(String postId, BrowseBusinessModel business) {
    // Keep this card active for Send; only clear the shared suggestion list.
    _searchCtrl.reset();
  }

  Future<void> _onMentionSubmit(
    String postId,
    String text,
    String image,
  ) async {
    // Keep the user on this post after submit (keyboard close + list rebuild
    // must not jump the NestedScrollView to the top) — same idea as home.
    final scrollable = Scrollable.maybeOf(context);
    final position = scrollable?.position;
    final savedOffset = position?.pixels;

    _dismissMentionUi();
    await widget.onMentionSubmit(postId, text, image);
    if (!mounted) return;
    _dismissMentionUi();

    void restoreScroll() {
      if (!mounted || savedOffset == null) return;
      final pos = Scrollable.maybeOf(context)?.position;
      if (pos == null || !pos.hasContentDimensions) return;
      pos.jumpTo(savedOffset.clamp(0.0, pos.maxScrollExtent));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      restoreScroll();
      Future<void>.delayed(const Duration(milliseconds: 280), restoreScroll);
    });
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
      final activeMentionId = _activeMentionPostId.value;
      final searchCtrl = _searchCtrl;

      // Touch search observables synchronously so this Obx subscribes to them.
      // They're otherwise only read inside itemBuilder (layout-time), so GetX
      // would never rebuild when results arrive — same pattern as home.
      if (activeMentionId != null) {
        searchCtrl.status.value;
        searchCtrl.businesses.length;
        searchCtrl.isPaginationLoading.value;
      }

      final me = _authController.userModelRx.value;
      final avatarRev = _authController.avatarRevision.value;
      final myAvatar = me?.avatar ?? '';

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final isActive = activeMentionId == announcement.id;
              final viewModel = PostCardViewModel.from(
                announcement,
                communityOwnerUserId: annCtrl.communityOwnerUserId.value,
              );

              return PostCardWidget(
                key: ValueKey('feed-post-${announcement.id}'),
                viewModel: viewModel,
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
                  widget.onPollTap(viewModel.postId);
                },
                onMentionChanged: _onMentionChanged,
                onMentionSubmit: _onMentionSubmit,
                onMentionBusinessSelected: _onMentionBusinessSelected,
                onMentionFocusChanged: _onMentionFocusChanged,
                mentionSuggestions: isActive
                    ? List<BrowseBusinessModel>.of(searchCtrl.businesses)
                    : const [],
                isMentionLoading: isActive && searchCtrl.isLoading,
                mentionSearchDone: isActive && searchCtrl.searchDone,
                isMentionActive: isActive,
                mentionHasNextPage: isActive && searchCtrl.hasNextPage,
                mentionIsPaginationLoading:
                    isActive && searchCtrl.isPaginationLoading.value,
                onMentionLoadMore:
                    isActive ? () => searchCtrl.loadNextPage() : null,
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
