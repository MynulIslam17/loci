import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Achievement / quick stats data
  final List<Map<String, dynamic>> achievementData = [
    {"icon": "assets/icons/calander.svg", "title": "Events"},
    {"icon": "assets/icons/map.svg", "title": "Routes"},
    {"icon": "assets/icons/rafel.svg", "title": "Raffles"},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 20),

            /// --- Profile Picture ---
            Align(
              alignment: Alignment.center,
              child: CustomCachedImage(
                width: 120,
                height: 120,
                imageUrl: "assets/images/user4.jpg",
                isCircle: true,
              ),
            ),

            const SizedBox(height: 10),

            /// --- User Name ---
            Text(
              "Nathan",
              style: AppTextStyle.textXl(
                color: colorScheme.primary,
                weight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            /// --- Membership Info ---
            Text(
              "Member since December 23, 2021",
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            /// --- About Section ---

             Text(
                "About",
                style: AppTextStyle.textMd(color: colorScheme.onSurface),
              ),

            const SizedBox(height: 5),

            Card(
              elevation: 2,
              color: colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Marland Clutch, founded in 1931, is a prominent global manufacturer "
                      "specializing in heavy duty industrial backstopping and overrunning clutches. "
                      "The company is currently a brand of Regal Rexnord Corporation",
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// --- Achievement / Stats Row ---
            Row(
              children: [
                ...achievementData.map(
                      (item) => Expanded(
                    child: Card(
                      color: colorScheme.surfaceContainer,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 15),
                          child: Column(
                            children: [

                              /// --- Icon Circle ---
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: SvgPicture.asset(
                                    item["icon"],
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// --- Count ---
                              Text(
                                "0",
                                style: AppTextStyle.textLg(
                                  color: colorScheme.onSurface,
                                  weight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// --- Title / Label ---
                              Text(
                                item["title"],
                                style: AppTextStyle.textSm(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}