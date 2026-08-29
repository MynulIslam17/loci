import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/event/presentation/controllers/event_list_controller.dart';
import 'package:loci/features/event/presentation/controllers/rsvp_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/routes/app_routes.dart';

import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/event/presentation/controllers/event_details_controller.dart';
import 'package:loci/shared/widgets/company_info_card.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import '../widgets/event_card.dart';
import '../widgets/event_details_skeleton.dart';
import '../widgets/event_map_preview.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({super.key});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  //--get x controller
  late final EventDetailsController eventDetailsController;
  late final RSVPController rsvpController;

  late final String eventId;
  bool _checkedInThisVisit = false;

  @override
  void initState() {
    super.initState();

    // Controllers are provided by EventBinding (route) and app bindings —
    // the UI only resolves them; it never wires domain services itself.
    eventDetailsController = Get.find<EventDetailsController>();
    rsvpController = Get.find<RSVPController>();

    final args = Get.arguments as Map<String, dynamic>?;
    eventId = args?["eventId"] ?? "";

    eventDetailsController.fetchEventDetails(eventId);
  }

  void _popWithResult() {
    Get.back(
      result: _checkedInThisVisit
          ? <String, dynamic>{
              'checkedIn': true,
              'entityId':
                  eventDetailsController.eventDetails?.eventModel.id ?? eventId,
              'activityType': 'event',
            }
          : null,
    );
  }

  ///------ Rsvp  handle
  void _rsvpOnTapHandler(String eventId) async {
    //call the api to change rsvp status
    bool success = await rsvpController.sendRSVP(
      eventId: eventId,
      status: RsvpStatus.going.toJson,
    );

    if (success) {
      ///---update the the rsvp status locally for event details screen
      eventDetailsController.updateRsvpStatus(RsvpStatus.going);

      ///---update the the rsvp status locally for event screen
      Get.find<EventListController>().updateRsvpStatus(
        eventId,
        RsvpStatus.going,
      );

      SnackbarService.success(rsvpController.successMessage!);
    } else {
      SnackbarService.error(rsvpController.errorMessage!);
    }
  }

  Future<void> _openCheckIn() async {
    final openEventId =
        eventDetailsController.eventDetails?.eventModel.id ?? eventId;

    final result = await Get.toNamed(
      AppRoutes.checkIn,
      arguments: {
        'type': 'event',
        'entityId': openEventId,
      },
    );

    if (result is Map && result['checkedIn'] == true) {
      final checkedInId = result['entityId']?.toString();
      // Disable only when the successful check-in is for this event.
      if (checkedInId == openEventId) {
        eventDetailsController.updateCheckInStatus(
          CheckInStatus.checkedIn,
          onlyIfId: openEventId,
        );
        _checkedInThisVisit = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _popWithResult();
      },
      child: Scaffold(
      appBar: const CustomAppbar(title: 'Event Details'),
      body: Obx(() {
        final controller = eventDetailsController;
        // --- Loading state
        if (controller.isLoading) {
          return const EventDetailsSkeleton();
        }

        // --- Error state
        if (controller.errorMessage != null) {
          return ErrorStateWidget(
            message: controller.errorMessage!,
            onRetry: () => controller.fetchEventDetails(eventId),
          );
        }

        // --- Content state
        final event = controller.eventDetails?.eventModel;
        final business = controller.eventDetails?.organizerBusiness;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        IconTextRow(
                          icon: Icons.calendar_today_outlined,
                          text: event?.dateLabel ?? "__",
                          iconColor: context.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        IconTextRow(
                          icon: Icons.location_on_outlined,
                          text: (event?.location.trim().isNotEmpty ?? false)
                              ? event!.location
                              : "__",
                          iconColor: context.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        IconTextRow(
                          icon: Icons.people_outline,
                          text:
                              "${event?.goingCount.toString()} going / ${event?.maxAttendees} max",
                          iconColor: context.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final controller = eventDetailsController;
                    final checkInStatus =
                        controller.eventDetails?.myCheckInStatus;
                    final isCheckedIn =
                        checkInStatus == CheckInStatus.checkedIn;

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isCheckedIn ? Icons.check_circle : Icons.qr_code,
                          size: 18,
                          color: context.colorScheme.onSurface,
                        ),
                        onPressed: isCheckedIn ? null : _openCheckIn,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: context.colorScheme.onSurface,
                          backgroundColor: isCheckedIn
                              ? context.colorScheme.surfaceContainerHigh
                              : context.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        label: Text(
                          checkInStatus?.label ?? 'Check In',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              Obx(() {
                return EventMapPreview(
                  mapImage: controller.eventDetails?.mapImage,
                  lat: controller.eventDetails?.lat,
                  lng: controller.eventDetails?.lng,
                  locationLabel: event?.title,
                  isLoading: controller.isLoading,
                );
              }),

              const SizedBox(height: 16),

              Text(
                "Owner",
                style: AppTextStyle.textMd(weight: FontWeight.w700),
              ),

              const SizedBox(height: 10),

              CompanyInfoCard(
                title: business?.name ?? "___",
                description: business?.description ?? "___",
                imagePath: business?.logo ?? "_",
              ),

              const SizedBox(height: 10),

              Obx(() {
                final controller = rsvpController;
                final isThisLoading =
                    controller.isLoading &&
                    controller.loadingEventId == eventId;

                return CustomButton(
                  isLoading: isThisLoading,
                  text: event?.myRsvpStatus.label,
                  onPressed: event?.myRsvpStatus == RsvpStatus.going
                      ? null
                      : () => _rsvpOnTapHandler(eventId),
                );
              }),
            ],
          ),
        );
      }),
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
