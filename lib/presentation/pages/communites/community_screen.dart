import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';
import 'package:loci/presentation/controllers/comment/announcement_controller.dart';
import 'package:loci/presentation/controllers/comment/announcements_comment_controller.dart';
import 'package:loci/presentation/controllers/community/my_community_controlle.dart';
import 'package:loci/presentation/controllers/community/vote_controller.dart';
import 'package:loci/presentation/controllers/event/rsvp_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/activity_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/community_member_header.dart';
import 'package:loci/presentation/pages/communites/widgets/community_owner_header.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/feed_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/notices_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/offers_tab.dart';
import 'package:loci/presentation/pages/communites/widgets/poll_bottom_sheet.dart';
import 'package:loci/presentation/pages/communites/widgets/post_comment_section.dart';
import 'package:loci/presentation/pages/communites/widgets/tabs/tab_body_wrapper.dart';
import '../../../data/models/community/announcement_model.dart';
import '../../controllers/community/announcement_like_controller.dart';

class CommunityScreen extends StatefulWidget {
  final CommunityRole? role;
  final String? communityId;
  final String? communityName;

  const CommunityScreen({super.key, this.role, this.communityId, this.communityName});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {

  late TabController tabController;
  final TextEditingController searchController = TextEditingController();
  final likeController = Get.find<AnnouncementLikeController>();

  final authController = Get.find<AuthController>();
  final announcementController = Get.find<AnnouncementController>();
  final myCommunityController = Get.find<MyCommunityController>();
  final voteController = Get.find<VoteController>();

  // -------------------------------------------------
  // LIFECYCLE
  // -------------------------------------------------
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

  // -------------------------------------------------
  // TAB LISTENER
  // -------------------------------------------------
  void _listenToTabChanges() {
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      switch (tabController.index) {
        case 0: announcementController.changeType(AnnouncementType.question); break;
        case 1: announcementController.changeType(AnnouncementType.offer); break;
        case 2: announcementController.changeType(AnnouncementType.notice); break;
        case 3: announcementController.changeType(AnnouncementType.activity); break;
        default: announcementController.changeType(AnnouncementType.activity);
      }
    });
  }

  // -------------------------------------------------
  // HANDLERS
  // -------------------------------------------------
  void _onVote(String announcementId, String optionId) async {


    final success = await voteController.submitVote(
      announcementId: announcementId,
      optionId: optionId,
    );

    if (success) {
     // announcementController.updatePollVote(announcementId, optionId);
      SnackbarService.success(voteController.successMessage!);
    } else {
      SnackbarService.error(voteController.errorMessage!);
    }
  }


  void _onLike(String postId) async {

   likeController.toggleLike(postId);

  }

  void _onRsvp(String eventId, RSVPController rsvpController) async {
    final success = await rsvpController.sendRSVP(
      eventId: eventId,
      status: RsvpStatus.going.toJson,
    );

    if (success) {
      announcementController.updateEventRsvpStatus(eventId, RsvpStatus.going);
      SnackbarService.success(rsvpController.successMessage!);
    } else {
      SnackbarService.error(rsvpController.errorMessage!);
    }
  }

  void _showCommentSheet(String announcementId) {
    final inputController = TextEditingController();
    final commentController = Get.find<CommentController>();
   
    commentController.fetchComments(postId: announcementId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {

        return GetBuilder<CommentController>(
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
        );
      },
    );
  }

  void _showPollSheet(AnnouncementModel announcement) {
    PollBottomSheet.show(
      context,
      announcement,
      onVote: (optionId) => _onVote(announcement.id, optionId),
    );
  }

  // -------------------------------------------------
  // BUILD
  // -------------------------------------------------
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
              TabBodyWrapper(builder: () => FeedTab(
                onCommentTap: _showCommentSheet,
                onPollTap: _showPollSheet,
                onLikeTap: _onLike,
              )),
              TabBodyWrapper(builder: () => OffersTab(
                searchController: searchController,
                onCommentTap: _showCommentSheet,
                onLikeTap: _onLike,
              )),
              TabBodyWrapper(builder: () => NoticesTab(
                searchController: searchController,
                onCommentTap: _showCommentSheet,
                onLikeTap: _onLike,
              )),
              TabBodyWrapper(builder: () => ActivityTab(
                searchController: searchController,
                onCommentTap: _showCommentSheet,
                onLikeTap: _onLike,
                onRsvp: _onRsvp,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------
// HEADER SLIVER
// -------------------------------------------------
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
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text("23601 Hoover Rd, Warren, MI 48089", style: AppTextStyle.textXs()),
              ],
            ),
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

// -------------------------------------------------
// TAB BAR SLIVER
// -------------------------------------------------
class _CommunityTabBar extends StatelessWidget {
  final TabController controller;
  final ColorScheme colorScheme;

  const _CommunityTabBar({required this.controller, required this.colorScheme});

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
