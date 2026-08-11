import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/data/models/activity_model.dart';
import 'package:loci/features/community/presentation/controllers/create_announcement_controller.dart';
import 'package:loci/features/community/presentation/controllers/search_activity_controller.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

/// Activity type selector, search field, suggestion list, and the selected
/// activity card for activity announcements.
class CreateAnnouncementActivitySection extends StatelessWidget {
  const CreateAnnouncementActivitySection({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onActivitySelected,
    this.searchFieldKey,
  });

  final CreateAnnouncementController controller;
  final TextEditingController searchController;
  final void Function(ActivityModel activity) onActivitySelected;

  /// Anchors the search field so the screen can scroll it above the keyboard
  /// when the results dropdown opens below it.
  final Key? searchFieldKey;

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
        Text(
          'Activity type',
          style: AppTextStyle.textSm(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: _activityTypes.map((type) {
              final isSelected = controller.activityRefType.value == type;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: type == _activityTypes.last ? 0 : 8,
                  ),
                  child: _TypeChip(
                    type: type,
                    isSelected: isSelected,
                    onTap: () {
                      if (isSelected) return;
                      controller.setActivityRefType(type);
                      searchController.clear();
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final selected = controller.selectedActivity.value;
          if (selected != null) {
            return _SelectedActivityCard(
              activity: selected,
              onClear: () {
                controller.clearActivitySelection();
                searchController.clear();
                controller.onActivityQueryChanged('');
              },
            );
          }
          return _ActivitySearchField(
            key: searchFieldKey,
            controller: controller,
            searchController: searchController,
            searchCtrl: searchCtrl,
            onActivitySelected: onActivitySelected,
          );
        }),
      ],
    );
  }
}

class _ActivitySearchField extends StatelessWidget {
  const _ActivitySearchField({
    super.key,
    required this.controller,
    required this.searchController,
    required this.searchCtrl,
    required this.onActivitySelected,
  });

  final CreateAnnouncementController controller;
  final TextEditingController searchController;
  final SearchActivityController searchCtrl;
  final void Function(ActivityModel activity) onActivitySelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final typeName =
              controller.activityRefType.value.name.toLowerCase();
          return CustomTextField(
            controller: searchController,
            title: 'Select $typeName',
            hintText: 'Search $typeName by name...',
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
            prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
          );
        }),
        Obx(() {
          if (!controller.showActivitySuggestions.value) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ActivitySuggestions(
              searchCtrl: searchCtrl,
              onSelected: onActivitySelected,
            ),
          );
        }),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final ActivityRefType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.12)
          : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.primary : colors.outline,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _iconFor(type),
                size: 20,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                type.name.capitalizeFirst ?? type.name,
                style: AppTextStyle.textXs(
                  color: isSelected ? colors.primary : colors.onSurface,
                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(ActivityRefType type) {
    switch (type) {
      case ActivityRefType.event:
        return Icons.event_outlined;
      case ActivityRefType.route:
        return Icons.route_outlined;
      case ActivityRefType.raffle:
        return Icons.card_giftcard_outlined;
      case ActivityRefType.unknown:
        return Icons.help_outline;
    }
  }
}

class _SelectedActivityCard extends StatelessWidget {
  const _SelectedActivityCard({
    required this.activity,
    required this.onClear,
  });

  final ActivityModel activity;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CustomCachedImage(
            imageUrl: activity.bannerUrl,
            height: 56,
            width: 56,
            borderRadius: 10,
            fallbackIcon: Icons.image_outlined,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 15,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Selected',
                      style: AppTextStyle.textXs(
                        color: colors.primary,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textSm(
                    color: colors.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
                if (activity.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textXs(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            tooltip: 'Change',
            icon: Icon(Icons.close, size: 20, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ActivitySuggestions extends StatelessWidget {
  const _ActivitySuggestions({
    required this.searchCtrl,
    required this.onSelected,
  });

  final SearchActivityController searchCtrl;
  final void Function(ActivityModel activity) onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: searchCtrl.isLoading.value
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : searchCtrl.activities.isEmpty
                ? _EmptyResults(colors: colors)
                : Column(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n is ScrollEndNotification &&
                              n.metrics.extentAfter < 60) {
                            searchCtrl.fetchMore();
                          }
                          return false;
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 280),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const ClampingScrollPhysics(),
                            itemCount: searchCtrl.activities.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              thickness: 1,
                              color: colors.outline.withValues(alpha: 0.5),
                            ),
                            itemBuilder: (context, index) {
                              final activity = searchCtrl.activities[index];
                              return _ActivityResultTile(
                                activity: activity,
                                onTap: () => onSelected(activity),
                              );
                            },
                          ),
                        ),
                      ),
                      if (searchCtrl.isPaginationLoading.value)
                        const PaginationLoader(size: 18, padding: 10),
                    ],
                  ),
      );
    });
  }
}

class _ActivityResultTile extends StatelessWidget {
  const _ActivityResultTile({
    required this.activity,
    required this.onTap,
  });

  final ActivityModel activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            CustomCachedImage(
              imageUrl: activity.bannerUrl,
              height: 48,
              width: 48,
              borderRadius: 8,
              fallbackIcon: Icons.image_outlined,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textSm(
                      color: colors.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (activity.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      activity.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.add_circle_outline,
              size: 20,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 28,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No activities found',
            style: AppTextStyle.textSm(
              color: colors.onSurface,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Try a different name or activity type.',
            textAlign: TextAlign.center,
            style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
