import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/carousel_data.dart';
import 'package:loci/presentation/pages/home/widgets/custom_carousel.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';
import 'package:loci/presentation/pages/home/widgets/post_interaction_bar.dart';
import 'package:loci/presentation/pages/home/widgets/post_poll_section.dart';
import 'package:loci/presentation/pages/raffles/active_raffles_screen.dart';
import 'package:loci/presentation/pages/home/widgets/expandable_text.dart';
import '../../../data/poll.dart';
import '../../../gen/assets.gen.dart';
import '../../controllers/nav_controller.dart';
import '../../widgets/common/post_comment_section.dart';
import 'widgets/user_post_header.dart';
import '../communites/community_screen.dart';

class HomeRoutes {
  static const community = '/community';
  static const communityDetail = '/community-detail';
}

class HomeNavigator extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
          case HomeRoutes.community:
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

  // --- Search bar controls ---
  final TextEditingController _postController = TextEditingController();
  final FocusNode _postFocusNode = FocusNode();

  // Comment section expansion flag
  bool _isCommentSectionExpanded = false;

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

  //-- Polls data ---
  final List<PollOption> myPolls = [
    PollOption(
      title: "Pizzaburg",
      percent: 0.8,
      imagePath: Assets.images.user2.path,
      trailingText: "80%",
    ),
    PollOption(
      title: "Chillox",
      percent: 0.4,
      imagePath: Assets.images.user1.path,
      trailingText: "40%",
    ),
  ];

  //-- Dummy comments ---
  final List<CommentData> myComments = List.generate(
    12,
        (index) => CommentData(
      userName: "Alexandra Broke",
      commentText:
      "This was one of the most epic experiences, that I've got myself involved in!",
      userImage: Assets.images.user2.path,
      likes: "200",
      replies: "2",
    ),
  );

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
                          HomeNavigator.push(HomeRoutes.community);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: context.colorScheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post header (user info)
                      UserPostHeader(
                        fullName: "Azaan Mahmud",
                        date: "12-01-26",
                        category: "Food",
                        imagePath: Assets.images.user1.path,
                      ),
                      const SizedBox(height: 20),

                      // Post content with expandable text
                      ExpandableText(
                        text: "Any food that you liked recently? " * 5,
                        trimLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Poll section
                      PostPollSection(options: myPolls),
                      const SizedBox(height: 20),

                      // Vote input field
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              Assets.images.user3.path,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              style: AppTextStyle.textSm(
                                color: context.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Vote your choose...',
                                hintStyle: AppTextStyle.textXs(
                                  color: context.colorScheme.onSurfaceVariant.withOpacity(0.6),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.colorScheme.outlineVariant.withOpacity(0.4),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Interaction bar (Like / Comment)
                      PostInteractionBar(
                        likes: "200",
                        comments: "45",
                        onLikeTap: () {},
                        onCommentTap: () {
                          setState(() {
                            _isCommentSectionExpanded = !_isCommentSectionExpanded;
                          });
                        },
                      ),

                      // expended Comment Section
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _isCommentSectionExpanded
                            ? Column(
                          children: [
                            const SizedBox(height: 8),
                            Divider(
                              color: context.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            PostCommentSection(
                              currentUserImage: Assets.images.user3.path,
                              comments: myComments,
                            ),
                          ],
                        )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}