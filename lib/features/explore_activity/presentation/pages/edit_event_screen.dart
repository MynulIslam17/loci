import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/event_edit_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_event_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_async_body.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_basic_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_cover_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_edit_save_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_form_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_location_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/form_labels.dart';

/// UI only — [EventEditController] → service → repository → API.
class EditEventScreen extends StatelessWidget {
  const EditEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventEditController>();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Edit Event'),
      body: Obx(() {
        final details = controller.eventDetails;
        return ExploreActivityAsyncBody(
          isLoading: controller.isLoadingDetails,
          errorMessage: controller.detailsError,
          onRetry: controller.loadDetails,
          isEmpty: details == null,
          emptyMessage: 'No event found',
          builder: (context) {
            final organizer = details!.organizerBusiness;

            // Reactive reads must run inside this Obx — it builds in the right
            // scope so text edits, banner, and visibility changes re-evaluate
            // hasChanged() and re-enable the Update button.
            return Obx(() {
              controller.formVersion.value;
              controller.bannerImage.value;
              controller.isPublic.value;

              return ExploreActivityFormScroll(
                formKey: controller.formKey,
                children: [
                  const RequiredFieldsNote(),
                  const SizedBox(height: 16),
                  ExploreActivityCoverSection(
                    imageUrl: details.eventModel.coverImage,
                    bannerImage: controller.bannerImage.value,
                    onSelected: controller.setBanner,
                    highlightTitle: true,
                  ),
                  ExploreActivitySection(
                    title: 'Basic information',
                    highlightTitle: true,
                  child: ExploreActivityBasicFields(
                    titleController: controller.titleController,
                    detailsController: controller.detailsController,
                    descriptionMaxLength: 200,
                    titleHint: 'e.g. Summer Block Party',
                      descriptionHint: 'Tell attendees what to expect',
                    ),
                  ),
                  ExploreActivitySection(
                    title: 'Schedule & capacity',
                    subtitle: 'When your event starts and how many can join',
                    highlightTitle: true,
                    child: CreateActivityEventFields(
                      dateController: controller.dateController,
                      timeController: controller.timeController,
                      personController: controller.personController,
                      onPickDate: () => controller.pickDate(context),
                      onPickTime: () => controller.pickTime(context),
                    ),
                  ),
                  ExploreActivityLocationSection(
                    locationController: controller.locationController,
                    urlController: controller.mapUrlController,
                    onLocationPicked: controller.setPickedLocation,
                    sectionSubtitle: 'Where participants will meet',
                    locationHint: 'e.g. 456 New St, Austin TX',
                    highlightTitle: true,
                    mapImage: details.mapImage,
                    latitude: controller.pickedLat.value,
                    longitude: controller.pickedLng.value,
                  ),
                  ExploreActivityEditSaveSection(
                    isPublic: controller.isPublic.value,
                    onPublicChanged: controller.setPublic,
                    organizerTitle: organizer.name,
                    organizerDescription: organizer.description,
                    organizerLogo:
                        organizer.logo ?? Assets.images.companyLogo.path,
                    primaryLabel: 'Update event',
                    isPrimaryEnabled: controller.hasChanged(),
                    isLoading: controller.isUpdating.value,
                    highlightTitle: true,
                    onPrimary: () {
                      FocusScope.of(context).unfocus();
                      controller.submit();
                    },
                  ),
                ],
              );
            });
          },
        );
      }),
    );
  }
}
