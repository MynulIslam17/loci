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
import '../../../data/mock_data.dart';
import '../../../data/poll.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/nav_controller.dart';
import '../../widgets/common/post_comment_section.dart';
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
                    print("Poll tapped on $postId");
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
}
