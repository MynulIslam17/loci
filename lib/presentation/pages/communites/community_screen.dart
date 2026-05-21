import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';
import 'package:loci/presentation/controllers/comment/announcements_comment_controller.dart';
import 'package:loci/presentation/controllers/community/announcement_controller.dart';
import 'package:loci/presentation/controllers/community/announcement_like_controller.dart';
import 'package:loci/presentation/controllers/community/my_community_controlle.dart';
import 'package:loci/presentation/controllers/community/poll_question_controller.dart';
import 'package:loci/presentation/controllers/community/post_poll_option_controller.dart';
import 'package:loci/presentation/controllers/community/vote_controller.dart';
import 'package:loci/presentation/controllers/event/rsvp_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/community_member_header.dart';
import 'package:loci/presentation/pages/communites/widgets/community_owner_header.dart';
import 'package:loci/presentation/pages/communites/widgets/poll_bottom_sheet.dart';
import 'package:loci/presentation/pages/communites/widgets/post_comment_section.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/activity_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/feed_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/notices_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/offers_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/tab_body_wrapper.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

class CommunityScreen extends StatefulWidget {
  final CommunityRole? role;
  final String? communityId;
  final String? communityName;

  const CommunityScreen({
    super.key,
    this.role,
    this.communityId,
    this.communityName,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  final authController = Get.find<AuthController>();
  final announcementController = Get.find<AnnouncementController>();
  final likeController = Get.find<AnnouncementLikeController>();
  final myCommunityController = Get.find<MyCommunityController>();
  final voteController = Get.find<VoteController>();
  final questionController = Get.find<PollQuestionController>();
  final postPollController = Get.find<PostPollOptionController>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);

    final communityId = widget.communityId;
    if (communityId != null && communityId.isNotEmpty) {
      announcementController.init(communityId);
      if (widget.role == CommunityRole.owner) {
        myCommunityController.fetchCommunity(communityId);
      }
    }

    _listenToTabChanges();
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // ── Tab listener ──────────────────────────────────────────────────────────

  void _listenToTabChanges() {
    tabController.addListener(() {
      switch (tabController.index) {
        case 0:
          announcementController.changeType(AnnouncementType.question);
          break;
        case 1:
          announcementController.changeType(AnnouncementType.offer);
          break;
        case 2:
          announcementController.changeType(AnnouncementType.notice);
          break;
        case 3:
          announcementController.changeType(AnnouncementType.activity);
          break;
      }
    });
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  /// Called when user submits a new question from PostInputField
  Future<void> _onPostQuestion(String text, String category) async {
    final communityId = widget.communityId;
    if (communityId == null) return;

    final success = await questionController.createPollQuestion(
      communityId: communityId,
      pollQuestion: text,
      pollCategory: category,
    );

    if (success) {
      announcementController.fetchAnnouncements(isRefresh: true);
    } else {
      SnackbarService.error(
          questionController.errorMessage ?? "Something went wrong");
    }
  }

  /// Called when user types a business name and submits (mention field)
  Future<void> _onMentionSubmit(String announcementId, String text, String image) async {
    final success = await postPollController.addPollOption(
      announcementId: announcementId,
      text: text,
      imageUrl: image.isNotEmpty ? image : null,
    );

    if (success) {
      announcementController.fetchAnnouncements(isRefresh: true);
    } else {
      SnackbarService.error(
          postPollController.errorMessage ?? "Failed to add option");
    }
  }

  void _onLike(String postId) {
    likeController.toggleLike(postId);
  }

  void _onVote(String announcementId, String optionId) async {
    final success = await voteController.submitVote(
      announcementId: announcementId,
      optionId: optionId,
    );

    if (success) {
      final user = authController.userModel;
      announcementController.updatePollVote(
        announcementId,
        optionId,
        userId: user?.id ?? '',
        userName: user?.name ?? '',
        userAvatar: user?.avatar ?? '',
      );
    } else {
      SnackbarService.error(voteController.errorMessage ?? "Vote failed");
    }
  }

  void _onRsvp(String eventId, RSVPController rsvpController) async {
    final success = await rsvpController.sendRSVP(
      eventId: eventId,
      status: RsvpStatus.going.toJson,
    );

    if (success) {
      announcementController.updateEventRsvpStatus(eventId, RsvpStatus.going);
      SnackbarService.success(rsvpController.successMessage ?? "RSVP sent");
    } else {
      SnackbarService.error(rsvpController.errorMessage ?? "RSVP failed");
    }
  }

  void _showCommentSheet(String announcementId) {
    final inputController = TextEditingController();
    final commentController = Get.find<CommentController>();
    commentController.fetchComments(postId: announcementId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GetBuilder<CommentController>(
        builder: (controller) => PostCommentSection(
          comments: controller.comments,
          controller: inputController,
          scrollController: controller.scrollController,
          paginationLoading: controller.isPaginationLoading,
          currentUserImage: authController.userModel?.avatar ?? "",
          isLoading: controller.isLoading,
          isSending: controller.isPosting,
          onSendTap: (text) => controller.postComment(
            content: text,
            postId: announcementId,
          ),
        ),
      ),
    );
  }

  void _showPollSheet(AnnouncementModel announcement) {
    PollBottomSheet.show(
      context,
      announcement,
      currentUserId: authController.userModel?.id,
      onVote: (optionId) => _onVote(announcement.id, optionId),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _CommunityHeader(
            communityName: widget.communityName,
            role: widget.role,
          ),
          _CommunityTabBar(
            controller: tabController,
            colorScheme: colorScheme,
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: TabBarView(
            controller: tabController,
            children: [
              TabBodyWrapper(
                shimmerBuilder: (ctx) => const _FeedShimmer(),
                stickyHeader: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PostInputField(
                    categories: BusinessCategory.values.map((e) => e.label).toList(),
                    initialCategory: BusinessCategory.foodie.label,
                    onSubmit: _onPostQuestion,
                    hintText: 'Post a question...',
                  ),
                ),
                builder: () => FeedTab(
                  onCommentTap: _showCommentSheet,
                  onPollTap: _showPollSheet,
                  onLikeTap: _onLike,
                  onMentionSubmit: _onMentionSubmit,
                ),
              ),
              TabBodyWrapper(
                builder: () => OffersTab(
                  searchController: searchController,
                  onCommentTap: _showCommentSheet,
                  onLikeTap: _onLike,
                ),
              ),
              TabBodyWrapper(
                builder: () => NoticesTab(
                  searchController: searchController,
                  onCommentTap: _showCommentSheet,
                  onLikeTap: _onLike,
                ),
              ),
              TabBodyWrapper(
                builder: () => ActivityTab(
                  searchController: searchController,
                  onCommentTap: _showCommentSheet,
                  onLikeTap: _onLike,
                  onRsvp: _onRsvp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header sliver ─────────────────────────────────────────────────────────────

class _CommunityHeader extends StatelessWidget {
  final String? communityName;
  final CommunityRole? role;

  const _CommunityHeader({this.communityName, this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              communityName ?? "",
              style: AppTextStyle.textMd(weight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 20),
            if (role == CommunityRole.owner)
              CommunityOwnerHeader()
            else
              const CommunityMemberHeader(),
          ],
        ),
      ),
    );
  }
}

// ── Tab bar sliver ────────────────────────────────────────────────────────────

class _CommunityTabBar extends StatelessWidget {
  final TabController controller;
  final ColorScheme colorScheme;

  const _CommunityTabBar(
      {required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
        pinned: true,
        toolbarHeight: 0,
        backgroundColor: colorScheme.surface,
        bottom: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface,
          indicatorColor: colorScheme.primary,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: "Feed"),
            Tab(text: "Offers"),
            Tab(text: "Notices"),
            Tab(text: "Activity"),
          ],
        ),
      ),
    );
  }
}

// ── Feed shimmer ──────────────────────────────────────────────────────────────

class _FeedShimmer extends StatelessWidget {
  const _FeedShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => const _PostCardSkeleton()),
    );
  }
}

class _PostCardSkeleton extends StatelessWidget {
  const _PostCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                SkeletonBox(width: 44, height: 44, radius: 22),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 13),
                    SizedBox(height: 6),
                    SkeletonBox(width: 80, height: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SkeletonBox(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const SkeletonBox(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const SkeletonBox(width: 200, height: 12),
            const SizedBox(height: 20),
            Row(
              children: const [
                SkeletonBox(width: 64, height: 28, radius: 8),
                SizedBox(width: 12),
                SkeletonBox(width: 64, height: 28, radius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}