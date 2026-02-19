import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/carousel_data.dart';
import 'package:loci/presentation/widgets/custom_carousel.dart';
import 'package:loci/presentation/widgets/expandable_text.dart';

import '../../../data/poll.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/post_comment_section.dart';
import '../../widgets/post_interaction_bar.dart';
import '../../widgets/post_poll_section.dart';
import '../../widgets/user_post_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  final List<Map<String, dynamic>> activity = [
    {"name": "Communities", "icon": Assets.icons.comunity},
    {"name": "Events", "icon": Assets.icons.event1},
    {"name": "Raffles", "icon": Assets.icons.ticket},
  ];

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

  final List<CommentData> myComments = [
    CommentData(
      userName: "Alexandra Broke",
      commentText: "This was one of the most epic experiences, that I've got myself involved in!",
      userImage: Assets.images.user2.path,
      likes: "200",
      replies: "2",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- 1. CAROUSEL SLIDER ---
            CustomCarousel(carouselData: bannerData),

            const SizedBox(height: 20),

            // --- 2. ACTIVITY ROW ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: activity.map((act) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
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

            // --- 3. POST CARD ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Card(
                elevation: 0, // Using 0 for modern flat design
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: context.colorScheme.outline.withOpacity(0.1)),
                ),
                color: context.colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      UserPostHeader(
                        fullName: "Azaan Mahmud",
                        date: "12-01-26",
                        category: "Food",
                        imagePath: Assets.images.user1.path,
                      ),

                      const SizedBox(height: 20),

                      // Post Content
                      ExpandableText(
                        text: "Any food that you liked recently? " * 5,
                        trimLines: 2,
                      ),

                      const SizedBox(height: 20),

                      // DYNAMIC POLL SECTION
                      PostPollSection(options: myPolls),

                      const SizedBox(height: 20),

                      // INTERACTION BAR (Like/Comment)
                      PostInteractionBar(likes: "200", comments: "45"),

                      const SizedBox(height: 8),
                      Divider(color: context.colorScheme.outline.withOpacity(0.2)),

                      const SizedBox(height: 20),

                      // DYNAMIC COMMENT SECTION
                      PostCommentSection(
                        currentUserImage: Assets.images.user3.path,
                        comments: myComments,
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