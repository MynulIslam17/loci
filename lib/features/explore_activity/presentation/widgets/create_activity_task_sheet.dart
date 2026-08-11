import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/data/models/activity_task_search_model.dart';
import 'package:loci/features/explore_activity/presentation/controllers/task_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/task_card.dart';

enum _TaskFilter { all, event, route }

void showCreateActivityTaskSheet({
  required BuildContext context,
  required String businessId,
  required void Function(List<TaskModel> tasks) onAddTasks,
  Set<String> alreadyAddedIds = const {},
}) {
  final taskController = Get.find<TaskController>();

  showModalBottomSheet<void>(
    backgroundColor: context.colorScheme.surface,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return _CreateActivityTaskSheetContent(
        businessId: businessId,
        taskController: taskController,
        alreadyAddedIds: alreadyAddedIds,
        onAddTasks: onAddTasks,
      );
    },
  );
}

class _CreateActivityTaskSheetContent extends StatefulWidget {
  const _CreateActivityTaskSheetContent({
    required this.businessId,
    required this.taskController,
    required this.alreadyAddedIds,
    required this.onAddTasks,
  });

  final String businessId;
  final TaskController taskController;
  final Set<String> alreadyAddedIds;
  final void Function(List<TaskModel> tasks) onAddTasks;

  @override
  State<_CreateActivityTaskSheetContent> createState() =>
      _CreateActivityTaskSheetContentState();
}

class _CreateActivityTaskSheetContentState
    extends State<_CreateActivityTaskSheetContent> {
  late final TextEditingController _searchController;
  final RxMap<String, TaskModel> _selected = <String, TaskModel>{}.obs;
  final Rx<_TaskFilter> _filter = _TaskFilter.all.obs;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    widget.taskController.reset();
    widget.taskController.fetchTasks(
      query: '',
      isRefresh: true,
      businessId: widget.businessId,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.taskController.reset();
    super.dispose();
  }

  bool _matchesFilter(TaskModel item, _TaskFilter filter) {
    final type = item.activityType.toLowerCase();
    return switch (filter) {
      _TaskFilter.all => true,
      _TaskFilter.event => type.contains('event') || !type.contains('route'),
      _TaskFilter.route => type.contains('route'),
    };
  }

  void _toggle(TaskModel item) {
    final id = item.id;
    if (id.isEmpty || widget.alreadyAddedIds.contains(id)) return;

    if (_selected.containsKey(id)) {
      _selected.remove(id);
    } else {
      _selected[id] = item;
    }
  }

  void _confirm() {
    final selected = _selected.values.toList();
    if (selected.isEmpty) return;
    widget.onAddTasks(selected);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.82;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.playlist_add_check_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entry requirements',
                          style: AppTextStyle.textLg(
                            weight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose events or routes participants must complete',
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: CustomTextField(
                controller: _searchController,
                hintText: 'Search by name…',
                borderColor: colorScheme.outline.withValues(alpha: 0.45),
                fontSize: 14,
                textColor: colorScheme.onSurface,
                hintTextColor: colorScheme.onSurfaceVariant,
                showClearButton: true,
                prefixIcon: exploreActivityFieldIcon(context, Icons.search),
                onChanged: (value) {
                  widget.taskController.fetchTasks(
                    query: value.trim(),
                    isRefresh: true,
                    businessId: widget.businessId,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Obx(() {
                final filter = _filter.value;
                final count = _selected.length;
                return Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: filter == _TaskFilter.all,
                      onTap: () => _filter.value = _TaskFilter.all,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Events',
                      icon: Icons.event_outlined,
                      selected: filter == _TaskFilter.event,
                      onTap: () => _filter.value = _TaskFilter.event,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Routes',
                      icon: Icons.route_outlined,
                      selected: filter == _TaskFilter.route,
                      onTap: () => _filter.value = _TaskFilter.route,
                    ),
                    const Spacer(),
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count selected',
                          style: AppTextStyle.textXs(
                            color: colorScheme.primary,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final taskController = widget.taskController;
                final selectedIds = _selected.keys.toSet();
                final filter = _filter.value;
                final visible = taskController.taskList
                    .where((t) => _matchesFilter(t, filter))
                    .toList();

                if (taskController.isLoading.value &&
                    taskController.taskList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (visible.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_outlined,
                    title: 'No activities found',
                    subtitle: 'Try another search or filter',
                    iconSize: 36,
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotify) {
                    if (scrollNotify.metrics.pixels >=
                        scrollNotify.metrics.maxScrollExtent - 200) {
                      if (!taskController.isPaginationLoading.value &&
                          taskController.hasMore.value) {
                        taskController.loadMoreTasks(
                          businessId: widget.businessId,
                        );
                      }
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: visible.length +
                        (taskController.isPaginationLoading.value ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= visible.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final item = visible[index];
                      final alreadyAdded =
                          widget.alreadyAddedIds.contains(item.id);
                      final isSelected = selectedIds.contains(item.id);

                      return _SelectableTaskTile(
                        item: item,
                        alreadyAdded: alreadyAdded,
                        isSelected: isSelected,
                        onTap: alreadyAdded ? null : () => _toggle(item),
                      );
                    },
                  ),
                );
              }),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Obx(() {
                    final selectedCount = _selected.length;
                    return CustomButton(
                      height: 52,
                      onPressed: selectedCount == 0 ? null : _confirm,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selectedCount == 0
                                ? Icons.check_circle_outline
                                : Icons.add_task_rounded,
                            size: 20,
                            color: selectedCount == 0
                                ? colorScheme.onSurface.withValues(alpha: 0.5)
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedCount == 0
                                ? 'Select requirements'
                                : 'Add $selectedCount requirement${selectedCount == 1 ? '' : 's'}',
                            style: AppTextStyle.textMd(
                              weight: FontWeight.w700,
                              color: selectedCount == 0
                                  ? colorScheme.onSurface
                                      .withValues(alpha: 0.5)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Material(
      color: selected
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyle.textXs(
                  weight: FontWeight.w600,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableTaskTile extends StatelessWidget {
  const _SelectableTaskTile({
    required this.item,
    required this.alreadyAdded,
    required this.isSelected,
    required this.onTap,
  });

  final TaskModel item;
  final bool alreadyAdded;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final typeLabel = TaskCard.typeLabelFromActivityType(item.activityType);
    final isRoute = typeLabel == 'Route';

    final borderColor = alreadyAdded
        ? colorScheme.outline.withValues(alpha: 0.18)
        : isSelected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.28);

    final background = alreadyAdded
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : isSelected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomCachedImage(
                  imageUrl: item.banner,
                  width: 56,
                  height: 56,
                  borderRadius: 12,
                  fallbackIcon: isRoute
                      ? Icons.route_outlined
                      : Icons.event_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isRoute
                            ? colorScheme.tertiary.withValues(alpha: 0.12)
                            : colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        alreadyAdded ? '$typeLabel · Added' : typeLabel,
                        style: AppTextStyle.textXs(
                          weight: FontWeight.w700,
                          color: alreadyAdded
                              ? colorScheme.onSurfaceVariant
                              : isRoute
                                  ? colorScheme.tertiary
                                  : colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w700,
                        color: alreadyAdded
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (item.details.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: alreadyAdded || isSelected
                      ? (alreadyAdded
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.35)
                          : colorScheme.primary)
                      : Colors.transparent,
                  border: Border.all(
                    color: alreadyAdded
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.35)
                        : isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.55),
                    width: 1.6,
                  ),
                ),
                child: alreadyAdded || isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: alreadyAdded
                            ? colorScheme.surface
                            : colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
