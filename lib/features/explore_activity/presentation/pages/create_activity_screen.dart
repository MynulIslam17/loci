import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/create_activity_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_bottom_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_event_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_raffle_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_route_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_top_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_cover_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_form_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/form_labels.dart';

class CreateActivityScreen extends GetView<CreateActivityController> {
  const CreateActivityScreen({super.key});

  String _categorySectionTitle(ActivityType type) {
    return switch (type) {
      ActivityType.event => 'Schedule & capacity',
      ActivityType.routes => 'Route schedule',
      ActivityType.raffles => 'Raffle setup',
    };
  }

  String? _categorySectionSubtitle(ActivityType type) {
    return switch (type) {
      ActivityType.event => 'When your event starts and how many can join',
      ActivityType.routes => 'When the route opens and how it is available',
      ActivityType.raffles => 'Duration, supply, and prize details',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Create Activity'),
      body: ExploreActivityFormScroll(
        formKey: controller.formKey,
        children: [
          const RequiredFieldsNote(),
          const SizedBox(height: 16),
          Obx(
            () => ExploreActivityCoverSection(
              bannerImage: controller.bannerImage.value,
              onSelected: controller.setBanner,
              highlightTitle: true,
            ),
          ),
          Obx(
            () => ExploreActivitySection(
              title: 'Basic information',
              highlightTitle: true,
              child: CreateActivityTopFields(
                selectedCategory: controller.selectedCategory.value,
                onCategoryChanged: controller.setCategory,
                titleController: controller.titleController,
                detailsController: controller.detailsController,
              ),
            ),
          ),
          Obx(() {
            final category = controller.selectedCategory.value;
            return ExploreActivitySection(
              title: _categorySectionTitle(category),
              subtitle: _categorySectionSubtitle(category),
              highlightTitle: true,
              child: switch (category) {
                ActivityType.event => CreateActivityEventFields(
                    dateController: controller.dateController,
                    timeController: controller.timeController,
                    personController: controller.personController,
                    onPickDate: () => controller.pickEventDate(context),
                    onPickTime: () => controller.pickTime(context),
                  ),
                ActivityType.routes => CreateActivityRouteFields(
                    timeController: controller.timeController,
                    selectedRouteCondition:
                        controller.selectedRouteCondition.value,
                    onPickTime: () => controller.pickTime(context),
                    onRouteTypeChanged: controller.setRouteType,
                  ),
                ActivityType.raffles => CreateActivityRaffleFields(
                    raffleDateController: controller.raffleDateController,
                    maxSupplyController: controller.maxSupplyController,
                    couponTitleController: controller.couponTitleController,
                    rafflePrizeImage: controller.rafflePrizeImage.value,
                    tasks: controller.tasks.toList(),
                    onPickRange: () => controller.pickRaffleRange(context),
                    onPickCoupon: controller.pickRaffleCoupon,
                    onClearCoupon: controller.clearRafflePrize,
                    onAddRequirement: () =>
                        controller.openAddTaskSheet(context),
                    onRemoveTask: controller.removeTaskAt,
                  ),
              },
            );
          }),
          Obx(
            () => ExploreActivitySection(
              title: 'Visibility & publish',
              highlightTitle: true,
              child: CreateActivityBottomSection(
                category: controller.selectedCategory.value,
                isPublic: controller.isPublic.value,
                onPublicChanged: controller.setPublic,
                businessName: controller.businessName,
                locationController: controller.locationController,
                urlController: controller.urlController,
                onLocationPicked: controller.setPickedLocation,
                isPublishLoading: controller.isLoading.value,
                onPublish: () => controller.handlePublish(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
