import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_event_details_controller.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../gen/assets.gen.dart';
import '../../controllers/event/event_details_controller.dart';
import '../../widgets/qrcode_maker.dart';
import '../event/widgets/event_card.dart';

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key});

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  late final String title;
  late final String eventId;

  final eventDetailsController = Get.find<BusinessEventDetailsController>();

  @override
  void initState() {
    super.initState();

    /// ===== GET ARGUMENTS =====
    var args = Get.arguments as Map<String, dynamic>?;

    title = args?["title"] ?? "";
    eventId = args?["eventId"] ?? "";

    /// ===== FETCH EVENT DETAILS =====
    eventDetailsController.fetchEventDetails(eventId);
  }

  /// ===== SHOW QR CODE BOTTOM SHEET =====
  void _qrCodeDownloadHandler(BuildContext context, String qrCode) {
    CustomQrCode.show(
      context,
      data: qrCode,
      title: "Spring Pub Crawl Festival",
      subtitle: "Scan this QR to check-in to this event",
      appName: "Loci",
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: CustomAppbar(title: title),

      /// ===== BODY =====
      body: GetBuilder<BusinessEventDetailsController>(
        builder: (controller) {
          /// ===== LOADING STATE =====
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ===== ERROR STATE =====
          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          /// ===== EMPTY STATE =====
          if (controller.eventDetails == null) {
            return const Center(child: Text("No event details found"));
          }


          //---------main part----------------

          final eventDetails = controller.eventDetails;
          final eventModel = eventDetails?.eventModel;
          final organization = eventDetails?.organizerBusiness;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== EVENT IMAGE =====
                CustomCachedImage(
                  imageUrl: eventModel?.coverImage,
                  height: 200,
                  width: double.infinity,
                  borderRadius: 10,
                ),
                const SizedBox(height: 16),

                /// ===== TITLE =====
                Text(
                  eventModel?.title ?? "__",
                  style: AppTextStyle.textMd(weight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                /// ===== DESCRIPTION =====
                Text(
                  eventModel?.description ?? "_",
                  style: AppTextStyle.textXs(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                /// ===== EVENT META =====
                IconTextRow(
                  icon: Icons.calendar_today_outlined,
                  text: eventModel?.date ?? "",
                  iconColor: context.colorScheme.primary,
                  textColor: colorScheme.onSurface,
                ),
                const SizedBox(height: 8),

                IconTextRow(
                  icon: Icons.location_on_outlined,
                  text: eventModel?.location ?? "__",
                  iconColor: context.colorScheme.primary,
                  textColor: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),

                IconTextRow(
                  icon: Icons.people_outline,
                  text: "${eventModel?.goingCount}/${eventModel?.maxAttendees}",
                  iconColor: context.colorScheme.primary,
                  textColor: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),

                /// ===== STATS =====
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.groups_outlined,
                        count: "${eventDetails?.rsvpCount}",
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
                        count: "${eventDetails?.checkInCount}",
                        label: "Check-Ins",
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.viewTotalCheckIn,
                            arguments: {"title": "Total Check-In"},
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// ===== QR BUTTON =====
                CustomButton(
                  onPressed: () => _qrCodeDownloadHandler(
                    context,
                    eventDetails?.qrCode ?? "",
                  ),
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

                /// ===== MAP =====
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

                /// ===== ORGANIZER =====
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
                          imageUrl: organization?.logo ?? "__",
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                organization?.name ?? "__",
                                style: AppTextStyle.textSm(
                                  weight: FontWeight.w600,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                organization?.description ?? "__",
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
          );
        },
      ),
    );
  }

  /// ===== STAT CARD =====
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
