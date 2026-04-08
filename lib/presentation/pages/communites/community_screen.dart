import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/presentation/pages/communites/widgets/activity_card.dart';
import 'package:loci/presentation/pages/communites/widgets/notice_card.dart';
import 'package:loci/presentation/pages/communites/widgets/offer_card.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card.dart';
import 'package:loci/presentation/pages/explore_routes/widgets/route_card.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../data/models/mock_data.dart';
import '../../../data/models/poll.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/post_comment_section.dart';
import '../../widgets/custom_text_field.dart';
import '../home/widgets/expandable_text.dart';
import '../home/widgets/post_interaction_bar.dart';
import '../home/widgets/post_poll_section.dart';
import '../home/widgets/user_post_header.dart';

/// Community screen showing business community content
/// with a collapsible header and tabbed lists.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  final offerTEController = TextEditingController();
  final noticeTEController = TextEditingController();
  final activityTEController = TextEditingController();

  // Comment section expansion with postId
  String? _expandedPostId;

  late TabController tabController;

  @override
  void initState() {
    super.initState();

    /// Controls TabBar and TabBarView
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      /// NestedScrollView allows the header + tab lists
      /// to scroll together properly
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            /// ---------------- HEADER SECTION ----------------
            /// Static community information (title, address, map)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Community title
                    Text(
                      "Marland Clutch’s Community",
                      style: AppTextStyle.textMd(weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),

                    /// Location row
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

                    // Display a widget whose design depends on the type of community.
                    // Pass `true` if the  user owns the Business Community,
                    // or `false` for a General/Others Community.
                    userTypeCommunityWidget(false),
                  ],
                ),
              ),
            ),

            /// ---------------- TAB BAR SECTION ----------------
            /// SliverOverlapAbsorber connects header scrolling
            /// with the inner tab lists.
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),

              sliver: SliverAppBar(
                pinned: true,
                toolbarHeight: 0,
                backgroundColor: colorScheme.surface,

                /// Tab navigation
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

        /// ---------------- TAB CONTENT ----------------
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: TabBarView(
            controller: tabController,
            children: [
              _buildTabBody(feedList()),
              _buildTabBody(offerList()),
              _buildTabBody(noticesList()),
              _buildTabBody(activityList()),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps each tab list with a CustomScrollView
  /// so it works correctly with NestedScrollView
  Widget _buildTabBody(Widget listWidget) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            /// Injects the overlap space from the header
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),

            /// Actual list content
            SliverToBoxAdapter(child: listWidget),
          ],
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
        //-- input field for post
        PostInputField(
          categories: const ['Food', 'Drinks', 'Restaurant', 'Entertainment'],
          initialCategory: "Food",
          onSubmit: (text, category) {
            print("Posting: $text in $category");
          },
          hintText: 'Post a question...',
        ),
        const SizedBox(height: 16),

        // --- posted posts ---
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
                  _expandedPostId = _expandedPostId == postId ? null : postId;
                });
              },
              onLikeTap: (postId) {
                print("Like tapped on $postId");
                // Your like logic here
              },
              onCommentTap: (postId) {
                print("Comment tapped on $postId");
                // Your comment logic here
              },
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
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        // Search Bar Row
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hintText: "Claim your Business",
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
            // Filter Button
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  print("Tapped!");
                },
                icon: const Icon(Icons.tune),
                color: context.colorScheme.onSurface,
                iconSize: 28,

                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Offers List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return CommunityOfferCard(
              profileImage: Assets.images.user1.path,
              businessName: "Marland Clutch",
              date: "04/09/25",
              time: "05:36:12",
              description:
                  "Black Friday Discount (\$200 value) limited coupon available, take it before it's get stock out...",
              couponImageUrl: Assets.images.finedine.path,
              likes: "200",

              comments: "0",
              onDownloadTap: () {
                print("Downloading coupon...");
              },
              onCommentTap: () {},
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
        //reusable search bar at the top
        _buildSearchBar(
          hintText: "Search notices",
          controller: noticeTEController,
          onFilterTap: () {
            // Add your filter logic here
          },
        ),

        const SizedBox(height: 20),

        //---  The List of Notice Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return CommunityNoticeCard(
              profileImage: Assets.images.user1.path,
              businessName: "Marland Clutch",
              date: "04/09/25",
              time: "05:36:12",
              noticeText:
                  "We are going to create a event for our business gathering...",
              likes: "200",
              comments: "0",
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
        //reusable search bar at the top
        _buildSearchBar(
          hintText: "Search activity",
          controller: activityTEController,
          onFilterTap: () {
            // Add your filter logic here
          },
        ),
        const SizedBox(height: 20),

        //  The List of Notice Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return CommunityActivityCard(
              profileImage: 'assets/images/user1.png',
              businessName: 'Marland Clutch',
              date: '12-03-26',
              time: '10:00 AM',
              description: 'Completed a new hiking route today!',
              likes: '120',
              comments: '15',
              // this activity content can be change according to the type of activity
              activityContent: index == 0
                  ? RouteCard(
                      title: "Spring Pub Crawl Festival",
                      description:
                          "Join us for the biggest pub crawl of the season! Visit 8 amazing bars in downtown and enjoy the night of your life, also there are special guest will participate too",
                      location: "",
                      openingTime: "222",
                      availabilityType: "easy",
                      imageUrl: "assets/images/finedine.png",
                    )
                  : CommunityNoticeCard(
                      profileImage: Assets.images.user1.path,
                      businessName: "Marland Clutch",
                      date: "04/09/25",
                      time: "05:36:12",
                      noticeText:
                          "We are going to create a event for our business gathering...",
                      likes: "200",
                      comments: "0",
                    ),
              onLikeTap: () {
                print('Liked activity!');
              },
              onCommentTap: () {
                print('Comment tapped!');
              },
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------
  // search bar
  // -------------------------------------------------

  Widget _buildSearchBar({
    required String hintText,
    required TextEditingController controller,
    VoidCallback? onFilterTap,
    Function(String)? onChanged,
  }) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            hintText: "Claim your Business",
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
        // Reusable Filter Button
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
  // User Type Community helper
  // -------------------------------------------------

  Widget userTypeCommunityWidget(bool isMe) {
    final colorScheme = context.colorScheme;
    switch (isMe) {
      case true:
        return Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              CustomCachedImage(
                width: double.infinity,
                imageUrl: "assets/images/location.png",
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // 1. Semi-transparent dark overlay for background contrast
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Marland Clutch Centre",
                    style:
                        AppTextStyle.textSm(
                          weight: FontWeight.bold,
                          color: Colors.white,
                        ).copyWith(
                          // 2. Direct Text Shadow for high-definition legibility
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        );

      case false:
        return Column(
          children: [
            //----card part
            Row(
              children: [
                //----card 1
                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1,
                    color: colorScheme.surfaceContainerHigh,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: (){
                        //TODO : got to member screen
                        Get.toNamed(AppRoutes.communityMemberScreen);

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.group,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "480K",
                                  style: AppTextStyle.textSm(
                                    weight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Member",
                              style: AppTextStyle.textMd(
                                weight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),
                //----card 2
                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,

                    elevation: 1,
                    color: colorScheme.surfaceContainerHigh,
                    child: InkWell(
                      onTap: (){

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.qr_code,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 10),
                            Text(
                              "Join QR code",
                              style: AppTextStyle.textSm(
                                weight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),






                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16,),


            CustomButton(
              onPressed: (){
                //TODO : got to announcement screen
                Get.toNamed(AppRoutes.createAnnouncement);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 10
                  ),

                  Text("Announcement ",style: AppTextStyle.textMd(weight: FontWeight.w600,color:colorScheme.onPrimary),)




                ],
              ),
            )
          ],
        );
    }
  }
}
