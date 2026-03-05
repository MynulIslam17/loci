import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';

class ViewRouteScreen extends StatefulWidget {
  const ViewRouteScreen({super.key});

  @override
  State<ViewRouteScreen> createState() => _ViewRouteScreenState();
}

class _ViewRouteScreenState extends State<ViewRouteScreen> {
  late String appBarTitle;

  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    appBarTitle = (args != null && args is Map) ? args["title"] ?? "Route Details" : "Route Details";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: appBarTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Banner Image (Read-only)
            _buildBanner(colorScheme),

            const SizedBox(height: 18),

            /// 2. Title & Description
            Text(
              "Spring Pub Crawl Festival",
              style: AppTextStyle.textMd(weight: FontWeight.w700, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              "Join us for the biggest pub crawl of the season! Visit 8 amazing bars in downtown and enjoy the night of your life...",
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            /// 3. Route Specific Details (Location, Time, Difficulty)
            _buildInfoRow(Icons.location_on_outlined, "Downtown District", colorScheme),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, "3.5 h", colorScheme),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.speed, "Easy", colorScheme),

            const SizedBox(height: 24),

            /// 4. Check-ins Counter Card
            _buildCheckInCounter(colorScheme),

            const SizedBox(height: 16),

            /// 5. Download QR Code Button
            CustomButton(
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 20),
                  const SizedBox(width: 10),
                  Text("Download QR code", style: AppTextStyle.textSm(weight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 6. Static Map View
            _buildMapPreview(colorScheme),

            const SizedBox(height: 24),

            /// 7. Organizer Section
            Text(
              "Organizer",
              style: AppTextStyle.textMd(weight: FontWeight.w700, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            CompanyInfoCard(
              title: "Marland Clutch",
              description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry...",
              imagePath: Assets.images.companyLogo.path,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(ColorScheme colorScheme) {
    return CustomCachedImage(
      height: 200,
      width: double.infinity,
      imageUrl: "assets/images/finedine.png",

    );
  }

  Widget _buildInfoRow(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildCheckInCounter(ColorScheme colorScheme) {
    return Center(
      child: Card(
        elevation: 2,
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    "0",
                    style: AppTextStyle.textLg(weight: FontWeight.w700, color: colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Check-ins",
                style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          Assets.images.location.path,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}