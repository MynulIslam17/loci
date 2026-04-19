import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/carousel_data.dart';
import 'package:loci/presentation/pages/home/widgets/custom_carousel.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';
import 'package:loci/presentation/pages/home/widgets/post_interaction_bar.dart';
import 'package:loci/presentation/pages/home/widgets/post_poll_section.dart';
import 'package:loci/presentation/pages/raffles/active_raffles_screen.dart';
import 'package:loci/presentation/pages/home/widgets/expandable_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../data/models/mock_data.dart';
import '../../../data/models/poll.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/nav_controller.dart';
import '../../widgets/common/post_comment_section.dart';
import '../../widgets/custom_image_container.dart';
import '../communites/widgets/post_card.dart';
import 'widgets/user_post_header.dart';
import '../communites/community_screen.dart';

class HomeNavigator extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const HomeNavigator({super.key});

  static void push(String route, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  static void pop() {
    navigatorKey.currentState?.pop();
  }

  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.communityScreen:
            return MaterialPageRoute(builder: (_) => const CommunityScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final navController = Get.find<NavController>();

  // Comment section expansion with postId
  String? _expandedPostId;

  // --- Search bar controls ---
  final TextEditingController _postController = TextEditingController();

  final FocusNode _postFocusNode = FocusNode();

  //-- Banner data ---
  final List<CarouselData> bannerData = [
    CarouselData(
      placeName: "Barclay Prime",
      placeLocation: "237 S 18th St, Philadelphia, PA 19103",
      placeWeather: "30",
      placeImage: Assets.images.finedine.path,
    ),
    CarouselData(
      placeName: "Pizzaburge",
      placeLocation: "Dhanmondi, Dhaka",
      placeWeather: "44",
      placeImage: Assets.images.restu.path,
    ),
  ];

  //-- Activity row data ---
  final List<Map<String, dynamic>> activity = [
    {"name": "Communities", "icon": Assets.icons.comunity},
    {"name": "Events", "icon": Assets.icons.event1},
    {"name": "Raffles", "icon": Assets.icons.ticket},
  ];

  @override
  void dispose() {
    _postFocusNode.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- 1️⃣ Carousel Slider ---
            CustomCarousel(carouselData: bannerData),
            const SizedBox(height: 20),

            // --- 2️⃣ Activity Row ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: activity.map((act) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      // Handle tap for each activity
                      switch (act["name"]) {
                        case "Raffles":
                          navController.openDrawerPage(
                            ActiveRafflesScreen(),
                            navigatorKey: ActiveRafflesScreen.navigatorKey,
                          );
                          break;

                        case "Communities":
                          HomeNavigator.push(AppRoutes.communityScreen);
                          break;

                        case "Events":
                          navController.changeIndex(2);
                          break;
                      }
                    },
                    child: SizedBox(
                      width: 100,
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(act["icon"]),
                          const SizedBox(height: 5),
                          Text(
                            act["name"],
                            style: AppTextStyle.textSm(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // --- 3️⃣ Post Input Field with Category Dropdown ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PostInputField(
                categories: ['Foodie', 'Drinks', 'Restaurant'],
                initialCategory: 'Foodie',
                hintText: 'Ask anything',
                onSubmit: (text, category) {
                  print("Posting: $text in $category");
                  // Handle post submission
                },
              ),
            ),

            // --- 4️⃣ Post Card ---
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
                      _expandedPostId = _expandedPostId == postId
                          ? null
                          : postId;
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
                  onClickPoll: (postId) {
                    //TODO : click on the poll section
                    _showAllPolls();
                  },

                  onSubmit: (postId, text) {
                    print("User typed '$text' for post $postId");
                  },
                  onChanged: (postId, value) {
                    print("User typing in post $postId: $value");
                  },
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //---- Show all polls in raffles bottom sheet ----
  void _showAllPolls() {
    final colorScheme = context.colorScheme;
    int? selectedIndex; // Tracks which poll option is selected

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take up more screen height
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // --- Drag handle at the top ---
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // --- Poll question ---
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Any food that you liked recently?" * 4,
                          style: AppTextStyle.textXs(
                            color: colorScheme.primary,
                            weight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Poll options list ---
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: mockPolls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final poll = mockPolls[index];
                            final isSelected = selectedIndex == index;

                            return _buildPollResultRow(
                              colorScheme: colorScheme,
                              isSelected: isSelected,
                              percent: poll.percent,
                              optionName: poll.title,
                              voteCount: poll.voteCount,
                              avatarUrl: poll.imagePath,
                              // Pass the callback to update selectedIndex when circle is tapped
                              onSelect: () {
                                setState(() {
                                  // remove vote from previous selection
                                  if (selectedIndex != null) {
                                    mockPolls[selectedIndex!].voteCount--;
                                  }
                                  // set new selection
                                  selectedIndex = index;

                                  // increment vote for selected option
                                  mockPolls[index].voteCount++;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  //---- Poll result row widget ----
  Widget _buildPollResultRow({
    required ColorScheme colorScheme,
    required bool isSelected,
    required double percent, // 0-1
    required String optionName,
    required int voteCount,
    required String avatarUrl,
    required VoidCallback onSelect, // Called when selection circle is tapped
  }) {
    return Row(
      children: [
        // --- 1. Vote count text ---
        SizedBox(
          width: 35,
          child: Text(
            voteCount.toString(),
            style: AppTextStyle.textSm(
              color: colorScheme.onSurface,
              weight: FontWeight.w500,
            ),
          ),
        ),

        // --- 2. User avatar ---
        CustomCachedImage(
          width: 40,
          height: 40,
          imageUrl: avatarUrl,
          isCircle: true,
        ),

        const SizedBox(width: 12),

        // --- 3. Option title & progress bar ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                optionName,
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearPercentIndicator(
                  lineHeight: 10.0,
                  percent: percent, // value between 0-1
                  backgroundColor: AppColors.base200,
                  progressColor: isSelected
                      ? AppColors.primaryG500
                      : AppColors.primaryG500.withOpacity(0.6),
                  barRadius: const Radius.circular(10),
                  animation: true,
                  animationDuration: 1000,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // --- 4. Selection circle ---
        GestureDetector(
          onTap: onSelect, // Only this circle is tappable
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF62B4AC), width: 1.5),
              color: isSelected ? const Color(0xFF62B4AC) : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }
}
