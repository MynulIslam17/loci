import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/activity_card.dart';
import 'package:loci/presentation/pages/communites/widgets/community_member_header.dart';
import 'package:loci/presentation/pages/communites/widgets/community_owner_header.dart';
import 'package:loci/presentation/pages/communites/widgets/notice_card.dart';
import 'package:loci/presentation/pages/communites/widgets/offer_card.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card.dart';
import 'package:loci/presentation/pages/communites/widgets/post_comment_section.dart';
import 'package:loci/presentation/pages/event/widgets/event_card.dart';
import 'package:loci/presentation/pages/explore_routes/widgets/route_card.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/data/models/mock_data.dart';
import 'package:loci/data/models/poll.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/presentation/controllers/comment/announcement_controller.dart';
import 'package:loci/presentation/controllers/comment/announcements_comment_controller.dart';
import 'package:loci/presentation/pages/raffles/widgets/raffle_card.dart';
import 'package:loci/presentation/widgets/common/post_comment_section.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/presentation/widgets/pagination_loading.dart';
import 'package:loci/data/community/announcement_model.dart';

import '../../../core/enums/acitivty_ref_type.dart';
import '../../../core/enums/activity_type.dart';

class CommunityScreen extends StatefulWidget {
  final CommunityRole? role;
  final String? communityId;

  const CommunityScreen({super.key, this.role, this.communityId});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {

  // -------------------------------------------------
  // CONTROLLERS
  // -------------------------------------------------
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  final authController = Get.find<AuthController>();
  final announcementController = Get.find<AnnouncementController>();

  // Comment section expansion with postId
  String? _expandedPostId;

  // -------------------------------------------------
  // LIFECYCLE
  // -------------------------------------------------
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);

    final communityId = widget.communityId;
    if (communityId != null && communityId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        announcementController.init(communityId);
      });
    }

    _tabSwitch();
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _tabSwitch() {
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;

      switch (tabController.index) {
        case 0:
          announcementController.changeType(AnnouncementType.activity);
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
        default:
          announcementController.changeType(AnnouncementType.activity);
      }
    });
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
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // ---------------- HEADER ----------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Marland Clutch's Community",
                      style: AppTextStyle.textMd(weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "23601 Hoover Rd, Warren, MI 48089",
                          style: AppTextStyle.textXs(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (widget.role == CommunityRole.owner)
                      const CommunityOwnerHeader()
                    else
                      const CommunityMemberHeader(),
                  ],
                ),
              ),
            ),

            // ---------------- TAB BAR ----------------
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                toolbarHeight: 0,
                backgroundColor: colorScheme.surface,
                bottom: TabBar(
                  controller: tabController,
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
            ),
          ];
        },

        // ---------------- TAB CONTENT ----------------
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: TabBarView(
            controller: tabController,
            children: [
              _buildTabBody(() => feedList()),
              _buildTabBody(() => offerList()),
              _buildTabBody(() => noticesList()),
              _buildTabBody(() => activityList()),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // TAB BODY WRAPPER
  // -------------------------------------------------
  Widget _buildTabBody(Widget Function() builder) {
    return Builder(
      builder: (context) {
        return GetBuilder<AnnouncementController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: () => controller.refreshAnnouncements(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    final isBottom =
                        metrics.pixels >= metrics.maxScrollExtent - 200;

                    if (isBottom &&
                        controller.hasMore &&
                        !controller.isPaginationLoading) {
                      controller.fetchMoreAnnouncements();
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    ),

                    // First load loader
                    if (controller.isLoading)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      // Actual content
                      SliverToBoxAdapter(child: builder()),

                      // Pagination loader
                      if (controller.isPaginationLoading)
                        const SliverToBoxAdapter(
                          child: PaginationLoader(
                            size: 18,
                            padding: 10,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------
  // FEED LIST
  // -------------------------------------------------
  Widget feedList() {
    return Column(
      children: [
        PostInputField(
          categories: const ['Food', 'Drinks', 'Restaurant', 'Entertainment'],
          initialCategory: "Food",
          onSubmit: (text, category) {
            print("Posting: $text in $category");
          },
          hintText: 'Post a question...',
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockPosts.length,
          itemBuilder: (context, index) {
            final post = mockPosts[index];
            return PostCardWidget(
              post: post,
              polls: mockPolls,
              comments: mockComments,
              expandedPostId: _expandedPostId,
              onExpandToggle: (postId) {
                setState(() {
                  _expandedPostId =
                  _expandedPostId == postId ? null : postId;
                });
              },
              onLikeTap: (postId) {},
              onCommentTap: (postId) {},
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------
  // OFFERS LIST
  // -------------------------------------------------
  Widget offerList() {
    return Column(
      children: [
        _buildSearchBar(
          hintText: "Search offers",
          onFilterTap: () {},
        ),
        const SizedBox(height: 20),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcementController.announcements.length,
          itemBuilder: (context, index) {
            final offer = announcementController.announcements[index];
            final business = offer.business;
            return CommunityOfferCard(
              profileImage: business?.logo ?? "",
              businessName: business?.name ?? "",
              dateTime: formatDateTime(offer.createdAt),
              description: offer.details,
              couponImageUrl: offer.image ?? "",
              likes: offer.likeCount.toString(),
              comments: offer.commentCount.toString(),
              onDownloadTap: () {},
              onCommentTap: () => _showCommentSheet(offer.id),
              onLikeTap: () {},
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------
  // NOTICES LIST
  // -------------------------------------------------
  Widget noticesList() {
    return Column(
      children: [
        _buildSearchBar(
          hintText: "Search notices",
          onFilterTap: () {},
        ),
        const SizedBox(height: 20),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcementController.announcements.length,
          itemBuilder: (context, index) {
            final notice = announcementController.announcements[index];
            final business = notice.business;
            return CommunityNoticeCard(
              profileImage: business?.logo ?? "",
              businessName: business?.name ?? "",
              dateTime: formatDateTime(notice.createdAt),
              noticeText: notice.details,
              likes: notice.likeCount.toString(),
              comments: notice.commentCount.toString(),
              onCommentTap: () => _showCommentSheet(notice.id),
              onLikeTap: () {},
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------
  // ACTIVITY LIST
  // -------------------------------------------------
  Widget activityList() {
    return Column(
      children: [
        _buildSearchBar(
          hintText: "Search activity",
          onFilterTap: () {},
        ),
        const SizedBox(height: 20),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcementController.announcements.length,
          itemBuilder: (context, index) {
            final activity = announcementController.announcements[index];
            final business = activity.business;
            return CommunityActivityCard(
              profileImage: business?.logo ?? "",
              businessName: business?.name ?? "",
              description: activity.details,
              likes: activity.likeCount.toString(),
              comments: activity.commentCount.toString(),
              activityContent: _buildActivityContent(activity),
              onLikeTap: () {},
              onCommentTap: () => _showCommentSheet(activity.id),
              dateTime: formatDateTime(activity.createdAt),

            );
          },
        ),
      ],
    );
  }

  Widget? _buildActivityContent(AnnouncementModel activity) {
    // 1. Check the enum type from your new ActivityRefType
    switch (activity.activityRefType) {

    // CASE: EVENT
      case ActivityRefType.event:
        final event = activity.event;
        if (event == null) return null;
        return EventCard(
          imageUrl: event.coverImage,
          title: event.title,
          description: event.description,
          date: event.date,
          location: event.location,
          attendance:"${event.goingCount}/${event.maxAttendees}",
          organizer: event.organizerName,
          onRSVP: () {},
          rsvpButtonText: "RSVP",
        );

    // CASE: ROUTE
      case ActivityRefType.route:
        final route = activity.route;
        if (route == null) return null;
        return RouteCard(
          title: route.title,
          description: route.details,
          location: route.location,
          openingTime: route.openingTime,
          availabilityType: route.availabilityType,
          imageUrl: route.banner,
        );

    // CASE: RAFFLE
      case ActivityRefType.raffle:
        final raffle=activity.raffle;
        if (raffle == null) return null;

        return RaffleCard(raffle: raffle, onTap: (){


        });

      default:
        return null;
    }
  }

  // -------------------------------------------------
  // COMMON SEARCH BAR
  // -------------------------------------------------
  Widget _buildSearchBar({
    required String hintText,
    VoidCallback? onFilterTap,
  }) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: CustomTextField(

            controller: searchController,
            hintText: hintText,
            borderColor: colorScheme.outline,
            fontSize: 14,
            textColor: colorScheme.onSurface,
            hintTextColor: colorScheme.onSurfaceVariant,
            suffixIcon: Icon(
              size: 20,
              Icons.search,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Icon(Icons.tune, color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // COMMENT BOTTOM SHEET
  // -------------------------------------------------
  void _showCommentSheet(String announcementId) {
    final controller = Get.find<CommentController>();
    controller.fetchComments(postId: announcementId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (builder) {
        final inputController = TextEditingController();
        return GetBuilder<CommentController>(
          builder: (controller) {
            return PostCommentSection(
              comments: controller.comments,
              controller: inputController,
              scrollController: controller.scrollController,
              paginationLoading: controller.isPaginationLoading,
              currentUserImage: authController.userModel?.avatar ?? "",
              isLoading: controller.isLoading,
              isSending: controller.isSending,
              onSendTap: (text) {
                controller.sendComment(
                    postId: announcementId, content: text);
              },
            );
          },
        );
      },
    );
  }
}