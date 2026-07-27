import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffles_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/create_activity_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_banner_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_bottom_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_event_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_raffle_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_route_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_task_sheet.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_top_fields.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

/// Form UI only — state and API live in [CreateActivityController].
class CreateActivityScreen extends StatelessWidget {
  const CreateActivityScreen({super.key});

  CreateActivityController get _c => Get.find<CreateActivityController>();

  Future<void> _onPublish(BuildContext context) async {
    final c = _c;
    final success = await c.publish(context);
    if (!context.mounted) return;

    if (success) {
      await _refreshListForCategory(c.selectedCategory.value, c.businessId);
      Get.back();
      SnackbarService.success(c.message.value);
      return;
    }

    if (c.message.value.isNotEmpty) {
      SnackbarService.warning(c.message.value);
    }
  }

  Future<void> _refreshListForCategory(
    ActivityType category,
    String businessId,
  ) async {
    switch (category) {
      case ActivityType.event:
        await Get.find<BusinessEventListController>().fetchEvents(
          businessId: businessId,
          forceRefresh: true,
        );
      case ActivityType.routes:
        await Get.find<BusinessRouteListController>().fetchRoutes(
          businessId: businessId,
          forceRefresh: true,
        );
      case ActivityType.raffles:
        await Get.find<BusinessRafflesListController>().fetchRaffles(
          businessId: businessId,
          forceRefresh: true,
        );
    }
  }

  void _onAddTask(BuildContext context) {
    showCreateActivityTaskSheet(
      context: context,
      businessId: _c.businessId,
      onAddTask: (task) {
        if (_c.isDuplicateTask(task)) {
          SnackbarService.warning('Task already added');
          return;
        }
        _c.addTask(task);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Create Activity'),
      body: SingleChildScrollView(
        child: Form(
          key: c.formKey,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Obx(() {
              final category = c.selectedCategory.value;

              return Column(
                children: [
                  CreateActivityBannerSection(
                    bannerImage: c.bannerImage.value,
                    onSelected: c.setBanner,
                  ),
                  const SizedBox(height: 16),
                  CreateActivityTopFields(
                    selectedCategory: category,
                    onCategoryChanged: c.setCategory,
                    titleController: c.titleController,
                    detailsController: c.detailsController,
                  ),
                  if (category == ActivityType.event)
                    CreateActivityEventFields(
                      dateController: c.dateController,
                      timeController: c.timeController,
                      personController: c.personController,
                      onPickDate: () => c.pickEventDate(context),
                      onPickTime: () => c.pickTime(context),
                    ),
                  if (category == ActivityType.routes)
                    CreateActivityRouteFields(
                      timeController: c.timeController,
                      selectedRouteCondition: c.selectedRouteCondition.value,
                      onPickTime: () => c.pickTime(context),
                      onRouteTypeChanged: c.setRouteType,
                    ),
                  if (category == ActivityType.raffles)
                    CreateActivityRaffleFields(
                      raffleDateController: c.raffleDateController,
                      maxSupplyController: c.maxSupplyController,
                      couponTitleController: c.couponTitleController,
                      rafflePrizeImage: c.rafflePrizeImage.value,
                      tasks: c.tasks.toList(),
                      onPickRange: () => c.pickRaffleRange(context),
                      onPickCoupon: c.pickRaffleCoupon,
                      onClearCoupon: c.clearRafflePrize,
                      onAddRequirement: () => _onAddTask(context),
                      onRemoveTask: c.removeTaskAt,
                    ),
                  CreateActivityBottomSection(
                    category: category,
                    isPublic: c.isPublic.value,
                    onPublicChanged: c.setPublic,
                    businessName: c.businessName,
                    locationController: c.locationController,
                    urlController: c.urlController,
                    isPublishLoading: c.isLoading.value,
                    onPublish: () => _onPublish(context),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
