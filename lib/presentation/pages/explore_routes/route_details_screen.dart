import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/routes/app_routes.dart';
import '../../widgets/custom_image_container.dart'; // Following your widget pattern

class RouteDetailsScreen extends StatefulWidget {
  const RouteDetailsScreen({super.key});

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  late String routeName;

  @override
  void initState() {
    super.initState();
    // Get arguments passed during navigation
    var args = Get.arguments;
    routeName = (args != null && args is Map) ? args["routeName"] : "Route Details";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        // Dynamic title from arguments
        title: Text(
          routeName,
          style: AppTextStyle.textMd(weight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Image Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomCachedImage(
                imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1000&auto=format",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                customBorderRadius: BorderRadius.circular(16), // Using your custom radius
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Downtown Pub Crawl",
                    style: AppTextStyle.textLg(weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Experience the best craft beer spots in downtown. Visit 8 amazing bars in downtown and enjoy the night of your life.",
                    style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  // 2. Info Section with Side Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side: Info Items
                      Expanded(
                        child: _buildInfoRow(colorScheme),
                      ),
                      // Right side: Check In Button
                      CustomButton(
                        width: 130,
                        height: 48,
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        onPressed: () {
                          Get.toNamed(AppRoutes.checkIn);
                        },

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_scanner, size: 18),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "Check In",
                                style: AppTextStyle.textSm(weight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Interactive Map Section
                  Card(
                    color: colorScheme.surfaceContainerHigh,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomCachedImage(
                        imageUrl: "assets/images/location.png",
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Owner Section
                  Text(
                    "Owner",
                    style: AppTextStyle.textMd(weight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 12),
                  _buildOwnerCard(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),


    );
  }



  Widget _buildInfoRow(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem(Icons.location_on_outlined, "Downtown District", colorScheme),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.access_time, "3.0 h", colorScheme),
        const SizedBox(height: 8),
        _buildInfoItem(Icons.explore_outlined, "Easy", colorScheme),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF66B9AD)), // Using accent teal
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant, weight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildOwnerCard(ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      elevation: 0,
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
                    style: AppTextStyle.textSm(weight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Providing the best experience for our community since 2010.",
                    style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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