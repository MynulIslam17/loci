import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/raffle_edit_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_raffle_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_async_body.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_basic_fields.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_cover_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_edit_save_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_form_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffle_tasks_block.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/form_labels.dart';
import 'package:loci/shared/widgets/task_card.dart';

class EditRafflesScreen extends StatelessWidget {
  const EditRafflesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaffleEditController>();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Edit Raffle'),
      body: Obx(() {
        final details = controller.raffleDetails;

        return ExploreActivityAsyncBody(
          isLoading: controller.isLoadingDetails,
          errorMessage: controller.detailsError,
          onRetry: controller.loadDetails,
          isEmpty: details == null,
          emptyMessage: 'Raffle not found',
          builder: (context) {
            final sponsor = details!.sponsor;

            // Reactive reads must run inside this Obx — it builds in the right
            // scope so text edits, banner, coupon, and visibility changes
            // re-evaluate hasChanged() and re-enable the Update button.
            return Obx(() {
              controller.formVersion.value;
              controller.bannerImage.value;
              controller.couponFile.value;
              controller.removeCoupon.value;
              controller.isPublic.value;

              return ExploreActivityFormScroll(
                formKey: controller.formKey,
                children: [
                  const RequiredFieldsNote(),
                  const SizedBox(height: 16),
                  ExploreActivityCoverSection(
                    imageUrl: controller.initialRaffle?.banner,
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
                      titleHint: 'e.g. Night Out Bundle Giveaway',
                      descriptionHint:
                          'Describe the prize and how winners are picked',
                    ),
                  ),
                  ExploreActivitySection(
                    title: 'Raffle setup',
                    subtitle: 'Duration, supply, and prize details',
                    highlightTitle: true,
                    child: CreateActivityRaffleFields(
                      raffleDateController: controller.dateController,
                      maxSupplyController: controller.maxSupplyController,
                      couponTitleController:
                          controller.raffleBundleNameTEController,
                      rafflePrizeImage: controller.couponFile.value,
                      couponImageUrl: controller.couponImageUrl,
                      tasks: const [],
                      showEntryRequirements: false,
                      onPickRange: () => controller.pickDateRange(context),
                      onPickCoupon: controller.pickCouponFile,
                      onClearCoupon: controller.removeCouponFile,
                      onAddRequirement: () {},
                      onRemoveTask: (_) {},
                    ),
                  ),
                  ExploreActivitySection(
                    title: 'Entry requirements',
                    subtitle:
                        'Add or remove tasks participants must complete to enter',
                    highlightTitle: true,
                    child: Obx(() {
                      controller.tasks.length;
                      controller.formVersion.value;

                      final taskCards = <Widget>[
                        for (var i = 0; i < controller.tasks.length; i++)
                          TaskCard(
                            key: ValueKey(
                              controller.tasks[i].activity?.id ?? 'task_$i',
                            ),
                            id: controller.tasks[i].activity?.id ?? '',
                            title:
                                controller.tasks[i].activity?.title ??
                                'No title',
                            description:
                                controller.tasks[i].activity?.details ??
                                'No description',
                            imageUrl:
                                controller.tasks[i].activity?.banner ?? '',
                            onRemove: () => controller.removeTaskAt(i),
                          ),
                      ];

                      return ExploreActivityRaffleTasksBlock(
                        showHeader: false,
                        taskCards: taskCards,
                        onAddRequirement: () =>
                            controller.openAddTaskSheet(context),
                      );
                    }),
                  ),
                  ExploreActivityEditSaveSection(
                    isPublic: controller.isPublic.value,
                    onPublicChanged: controller.togglePublic,
                    organizerTitle: sponsor.name,
                    organizerDescription: sponsor.description,
                    organizerLogo: sponsor.logo,
                    primaryLabel: 'Update raffle',
                    isPrimaryEnabled: controller.hasChanged(),
                    isLoading: controller.isLoading.value,
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
