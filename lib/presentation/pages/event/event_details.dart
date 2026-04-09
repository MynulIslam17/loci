
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/error_state.dart';

import '../../../gen/assets.gen.dart';
import '../../controllers/event/event_details_controller.dart';
import '../../widgets/common/company_info_card.dart';
import 'widgets/event_card.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({super.key});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  //--get x controller
  late final EventDetailsController eventDetails;

  late final String eventId;
  late final String eventTitle;

  @override
  void initState() {
    super.initState();


    if(Get.isRegistered<EventDetailsController>()){
      eventDetails=Get.find<EventDetailsController>();
    }else{
      eventDetails=Get.put(EventDetailsController());
    }

    //---get the event id
    final args = Get.arguments as Map<String, dynamic>?;
    eventId = args?["eventId"] ?? "";
    eventTitle = args?["eventTitle"] ?? "";

    // fetch event details
    eventDetails.fetchEventDetails(eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          eventTitle,
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),
      body: GetBuilder<EventDetailsController>(
        builder: (controller) {
          // --- Loading state
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Error state
          if (controller.errorMessage != null) {
            return ErrorStateWidget(
              errorMessage: controller.errorMessage,
              onRetry: () {
                controller.fetchEventDetails(eventId);
              },
            );
          }

          // --- Content state
          final event = controller.eventDetails?.eventModel;
          final business = controller.eventDetails?.organizerBusiness;
          final lat = controller.eventDetails?.lat;
          final lng = controller.eventDetails?.lng;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //--- top image--
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomCachedImage(
                    imageUrl: event?.coverImage,
                    height: 200,
                    width: double.infinity,
                    borderRadius: 10,
                  ),
                ),

                const SizedBox(height: 16),
                // ---- header section----
                _buildEventHeader(
                  title: event?.title ?? "__",
                  description: event?.description ?? "__",
                ),
                const SizedBox(height: 16),

                //--- event Info Rows
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          IconTextRow(
                            icon: Icons.calendar_today_outlined,
                            text: event?.date ?? "__",
                            iconColor: context.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          IconTextRow(
                            icon: Icons.location_on_outlined,
                            text: "Downtown District",
                            iconColor: context.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          IconTextRow(
                            icon: Icons.people_outline,
                            text: event?.attendanceText ?? "__",
                            iconColor: context.colorScheme.primary,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.qr_code,
                        color: context.colorScheme.onSurface,
                      ),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: context.colorScheme.onSurface,
                        backgroundColor: context.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      label: const Text("Check In"),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Card(
                  color: context.colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      child: Image.asset(Assets.images.location.path),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Owner",
                  style: AppTextStyle.textMd(weight: FontWeight.w700),
                ),

                const SizedBox(height: 10),

                CompanyInfoCard(
                  title: business?.name ?? "___",
                  description: business?.name ?? "___",
                  imagePath: business?.logo ?? "_",
                ),

                const SizedBox(height: 10),

                CustomButton(text: "RSVP", onPressed: () {}),
              ],
            ),
          );
        },
      ),
    );
  }

  //--- helper widgets--------
  Widget _buildEventHeader({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.textMd(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
