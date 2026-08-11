import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/route_edit_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_route_fields.dart';
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

class EditRoutesScreen extends StatelessWidget {
  const EditRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RouteEditController>();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Edit Route'),
      body: Obx(() {
        final routeDetails = controller.routeDetails;

        return ExploreActivityAsyncBody(
          isLoading: controller.isLoadingDetails,
          errorMessage: controller.detailsError,
          onRetry: controller.loadDetails,
          isEmpty: routeDetails == null,
          emptyMessage: 'No route found',
          builder: (context) {
            final organizer = routeDetails!.organizerBusiness;

            // Reactive reads must run inside this Obx — it builds in the right
            // scope so text edits, banner, availability, and visibility changes
            // re-evaluate hasChanged() and re-enable the Update button.
            return Obx(() {
              controller.formVersion.value;
              controller.bannerImage.value;
              controller.isPublic.value;
              controller.availabilityType.value;

              return ExploreActivityFormScroll(
                formKey: controller.formKey,
                children: [
                  const RequiredFieldsNote(),
                  const SizedBox(height: 16),
                  ExploreActivityCoverSection(
                    imageUrl: controller.route!.banner,
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
                    titleHint: 'e.g. Downtown Pub Crawl',
                      descriptionHint: 'Describe the route and its stops',
                    ),
                  ),
                  ExploreActivitySection(
                    title: 'Route schedule',
                    subtitle: 'When the route opens and how it is available',
                    highlightTitle: true,
                    child: CreateActivityRouteFields(
                      timeController: controller.timeController,
                      selectedRouteCondition: controller.availabilityType.value,
                      onPickTime: () => controller.pickTime(context),
                      onRouteTypeChanged: controller.setAvailabilityType,
                    ),
                  ),
                  ExploreActivityLocationSection(
                    locationController: controller.locationController,
                    urlController: controller.mapUrlController,
                    onLocationPicked: controller.setPickedLocation,
                    sectionSubtitle: 'Starting point',
                    locationHint: 'e.g. Downtown Austin, TX',
                    highlightTitle: true,
                    mapImage: routeDetails.mapImage,
                    latitude: controller.pickedLat.value,
                    longitude: controller.pickedLng.value,
                  ),
                  ExploreActivityEditSaveSection(
                    isPublic: controller.isPublic.value,
                    onPublicChanged: controller.setPublic,
                    organizerTitle: organizer.name,
                    organizerDescription: organizer.description ?? '',
                    organizerLogo:
                        organizer.logo ?? Assets.images.companyLogo.path,
                    primaryLabel: 'Update route',
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
