import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/controllers/create_announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/search_activity_controller.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

/// Activity type, search field, and suggestion list for activity announcements.
class CreateAnnouncementActivitySection extends StatelessWidget {
  const CreateAnnouncementActivitySection({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onActivityTitleSelected,
  });

  final CreateAnnouncementController controller;
  final TextEditingController searchController;
  final void Function(String id, String title) onActivityTitleSelected;

  static const _activityTypes = [
    ActivityRefType.event,
    ActivityRefType.route,
    ActivityRefType.raffle,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final searchCtrl = Get.find<SearchActivityController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => CustomDropdown(
            title: 'Activity type',
            dropdownColor: colors.surfaceContainerHigh,
            borderColor: colors.outline,
            hintText: 'Select activity type',
            textFontSize: 14,
            hintFontSize: 14,
            hintColor: colors.onSurfaceVariant,
            textColor: colors.onSurface,
            value: controller.activityRefType.value.name,
            items: _activityTypes
                .map(
                  (t) => DropdownMenuItem(
                    value: t.name,
                    child: Text(t.name.capitalizeFirst ?? t.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              controller.setActivityRefType(ActivityRefType.fromString(value));
              searchController.clear();
            },
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: searchController,
          title: 'Activity',
          hintText: 'Search activity...',
          borderColor: colors.outline,
          fontSize: 14,
          textColor: colors.onSurface,
          hintTextColor: colors.onSurfaceVariant,
          showClearButton: true,
          onClear: () {
            searchController.clear();
            controller.clearActivitySelection();
            controller.onActivityQueryChanged('');
          },
          onChanged: controller.onActivityQueryChanged,
          suffixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
        ),
        Obx(() {
          if (!controller.showActivitySuggestions.value) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _ActivitySuggestions(
              searchCtrl: searchCtrl,
              onSelected: onActivityTitleSelected,
            ),
          );
        }),
      ],
    );
  }
}

class _ActivitySuggestions extends StatelessWidget {
  const _ActivitySuggestions({
    required this.searchCtrl,
    required this.onSelected,
  });

  final SearchActivityController searchCtrl;
  final void Function(String id, String title) onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline),
        ),
        child: searchCtrl.isLoading.value
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : searchCtrl.activities.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No activities found',
                      style: AppTextStyle.textSm(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n is ScrollEndNotification &&
                              n.metrics.extentAfter < 50) {
                            searchCtrl.fetchMore();
                          }
                          return false;
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: searchCtrl.activities.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: colors.outline,
                            ),
                            itemBuilder: (context, index) {
                              final activity = searchCtrl.activities[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  activity.title,
                                  style: AppTextStyle.textSm(
                                    color: colors.onSurface,
                                  ),
                                ),
                                onTap: () => onSelected(
                                  activity.id,
                                  activity.title,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (searchCtrl.isPaginationLoading.value)
                        const PaginationLoader(size: 18, padding: 8),
                    ],
                  ),
      );
    });
  }
}
