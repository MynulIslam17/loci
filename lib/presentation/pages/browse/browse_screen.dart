import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<Map<String, dynamic>> placeCategory = [
    {"Icon": Assets.icons.care, "title": "Boutiques & Beauty"},
    {"Icon": Assets.icons.foodie, "title": "Foodie"},
    {"Icon": Assets.icons.advanture, "title": "Adventure"},
    {"Icon": Assets.icons.party, "title": "Party Like a Loci"},
    {"Icon": Assets.icons.helth, "title": "Wellness"},
    {"Icon": Assets.icons.repair, "title": "Home and Repair"},
    {"Icon": Assets.icons.nonProfit, "title": "Non Profits"},
    {"Icon": Assets.icons.local, "title": "Local Services"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover your place",
                  style: AppTextStyle.textXl(
                    weight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "What are you in the mood for today?",
                  style: AppTextStyle.textSm(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: placeCategory.length,
                  itemBuilder: (context, index) {
                    final item = placeCategory[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      color: context.colorScheme.surfaceContainerHigh,
                      child: InkWell(
                        onTap: _placeHandler,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              item["Icon"],
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                context.colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item["title"],
                              textAlign: TextAlign.center,
                              style: AppTextStyle.textSm(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _placeHandler() {

    Get.toNamed(AppRoutes.browseBusiness);

  }
}
