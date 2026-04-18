import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../gen/assets.gen.dart';
import '../../widgets/qrcode_maker.dart';
import '../event/widgets/event_card.dart';

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key});

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  late String title;

  @override
  void initState() {
    super.initState();

    var args = Get.arguments;
    if (args != null && args is Map && args["title"] != null) {
      title = args["title"];
    } else {
      title = "Event Details";
    }
  }

  //----- to show qr code
  _qrCodeDownloadHandler() {
    CustomQrCode.show(
      context,
      data:
          "eyJlbnRpdHlUeXBlIjoiZXZlbnQiLCJlbnRpdHlJZCI6IjY5ZDlkZDY5Y2UwNDE2Mjk5YTkwYzRiZiIsImlzc3VlZEF0IjoxNzc1ODg1NjczNDg1fQ.e73ecb2f79afbf1a8e724d16240080077b003edff3892a537351e0e199909fa8",
      title: "Event Check-In Code",
      subtitle:  "Spring Pub Crawl Festival",
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      appBar: CustomAppbar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Event Image ---
            CustomCachedImage(
              imageUrl: "assets/images/finedine.png",
              height: 200,
              width: double.infinity,
              borderRadius: 10,
            ),
            const SizedBox(height: 16),

            // --- Header & Description ---
            Text(
              "Spring Pub Crawl Festival",
              style: AppTextStyle.textMd(weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              "Join us for the biggest pub crawl of the season! Visit 8 amazing bars in downtown and enjoy the night of your life...",
              style: AppTextStyle.textXs(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // --- Event Metadata ---
            IconTextRow(
              icon: Icons.calendar_today_outlined,
              text: "Mon, Jan 19 at 2:50 PM",
              iconColor: context.colorScheme.primary,
              textColor: colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            IconTextRow(
              icon: Icons.location_on_outlined,
              text: "Downtown District",
              iconColor: context.colorScheme.primary,
              textColor: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            IconTextRow(
              icon: Icons.people_outline,
              text: "0 going / 200 max",
              iconColor: context.colorScheme.primary,
              textColor: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),

            // --- RSVP & Check-In Stats Cards ---
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.groups_outlined,
                    count: "0",
                    label: "Total RSVP",
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.viewTotalRSVP,
                        arguments: {"title": "Total RSVP"},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.person_search_outlined,
                    count: "0",
                    label: "Check-Ins",
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.viewTotalCheckIn,
                        arguments: {"title": "Total Checkin"},
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Download QR Button ---
            CustomButton(
              //icon: Icons.qr_code_scanner,
              onPressed: _qrCodeDownloadHandler,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.qr_code, color: context.colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    "View QR code",
                    style: AppTextStyle.textMd(
                      color: colorScheme.onPrimary,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Map Section ---
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: context.colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    Assets.images.location.path,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Organizer Section ---
            Text(
              "Organizer",
              style: AppTextStyle.textMd(weight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              color: context.colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    CustomCachedImage(
                      width: 90,
                      height: 90,
                      imageUrl: "assets/images/finedine.png",
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Marland Clutch",
                            style: AppTextStyle.textSm(
                              weight: FontWeight.w600,
                              color: context.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: context.colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: context.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    count,
                    style: AppTextStyle.textLg(weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyle.textXs(
                  color: context.colorScheme.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
