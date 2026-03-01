import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_image_container.dart';

class RafflesDetailsScreen extends StatefulWidget {
  const RafflesDetailsScreen({super.key});

  @override
  State<RafflesDetailsScreen> createState() => _RafflesDetailsScreenState();
}

class _RafflesDetailsScreenState extends State<RafflesDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Image with Custom Radius
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomCachedImage(
                imageUrl:
                    "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1000&auto=format",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                customBorderRadius: BorderRadius.circular(16),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Description
                  Text(
                    "Coffee Lovers Bundle",
                    style: AppTextStyle.textLg(weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Experience the best craft beer spots in downtown. Visit 8 amazing bars in downtown and enjoy the night of your life.",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prize Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Premium Coffee Bundle (\$200 value)",
                      style: AppTextStyle.textSm(
                        color: colorScheme.primary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Ends Jan 26, 2026",
                    style: AppTextStyle.textXs(color: AppColors.danger),
                  ),

                  const SizedBox(height: 24),

                  // 2. Progress Section
                  Text(
                    "Checked-in status:",
                    style: AppTextStyle.textMd(
                      weight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "You're doing great! Keep it up.",
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "70%",
                        style: AppTextStyle.textSm(
                          weight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: 0.7,
                    padding: EdgeInsets.zero,
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    progressColor: colorScheme.primary,
                    barRadius: const Radius.circular(10),
                    animation: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "3 of 4 tasks completed",
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "1 remaining",
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Interactive Task List
                  Card(
                    color: colorScheme.surfaceContainerHigh,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildTaskItem("Devid Smith", true, colorScheme),
                          _buildTaskItem("Central Pub", true, colorScheme),
                          _buildTaskItem("Downtown Grill", true, colorScheme),
                          _buildTaskItem("The Beer Garden", false, colorScheme),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Sponsor Card
                  Text(
                    "Sponsor",
                    style: AppTextStyle.textMd(weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSponsorCard(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Task Item Helper with Click Functionality
  Widget _buildTaskItem(
    String name,
    bool isCompleted,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            // Tap icon to trigger action
            GestureDetector(
              onTap: () {
                if (!isCompleted) {
                  // Navigate to your QR Scanner or trigger check-in
                  Get.toNamed(AppRoutes.routeDetails,arguments: {
                    "routeName": name
                  });
                }
              },
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.add_circle,
                color: isCompleted ? Colors.green : colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),

            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCompleted ? Colors.green : colorScheme.primary,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: CustomCachedImage(
                imageUrl: "assets/images/finedine.png",
                width: 20,
                height: 20,
                isCircle: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyle.textSm(weight: FontWeight.bold),
                  ),
                  Text(
                    "Click the icon to check-in at this location",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sponsor Card Helper
  Widget _buildSponsorCard(ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 80,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomCachedImage(
                imageUrl: "assets/images/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Marland Clutch",
                    style: AppTextStyle.textSm(
                      weight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Official partner of Loci events and local crawls.",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
