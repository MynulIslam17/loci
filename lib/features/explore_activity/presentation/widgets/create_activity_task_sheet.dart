import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/data/models/activity_task_search_model.dart';
import 'package:loci/features/explore_activity/presentation/controllers/task_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/empty_state.dart';

void showCreateActivityTaskSheet({
  required BuildContext context,
  required String businessId,
  required void Function(TaskModel task) onAddTask,
}) {
  final taskController = Get.find<TaskController>();

  showModalBottomSheet<void>(
    backgroundColor: context.colorScheme.surface,
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return _CreateActivityTaskSheetContent(
        businessId: businessId,
        taskController: taskController,
        onAddTask: onAddTask,
      );
    },
  );
}

class _CreateActivityTaskSheetContent extends StatefulWidget {
  const _CreateActivityTaskSheetContent({
    required this.businessId,
    required this.taskController,
    required this.onAddTask,
  });

  final String businessId;
  final TaskController taskController;
  final void Function(TaskModel task) onAddTask;

  @override
  State<_CreateActivityTaskSheetContent> createState() =>
      _CreateActivityTaskSheetContentState();
}

class _CreateActivityTaskSheetContentState
    extends State<_CreateActivityTaskSheetContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    widget.taskController.reset();
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.taskController.reset();
    super.dispose();
  }

  /// Modest default height; shrinks when the keyboard is open so layout never overflows.
  double _sheetHeight(MediaQueryData mq) {
    const verticalReserve = 28.0;
    const minComfortable = 200.0;

    final maxAvailable = mq.size.height -
        mq.padding.top -
        mq.viewInsets.bottom -
        verticalReserve;

    if (maxAvailable <= 0) return 0;

    // Shorter sheet when keyboard is closed (~half screen, capped on tall phones).
    const maxPreferred = 420.0;
    final preferred = (mq.size.height * 0.52).clamp(minComfortable, maxPreferred);

    if (maxAvailable < minComfortable) {
      return maxAvailable;
    }
    return preferred > maxAvailable ? maxAvailable : preferred;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final colorScheme = context.colorScheme;
    final sheetHeight = _sheetHeight(mq);
    if (sheetHeight <= 0) {
      return const SizedBox.shrink();
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Add Requirement',
                          style: AppTextStyle.textLg(
                            weight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 12),
                  child: CustomTextField(
                  controller: _searchController,
                  hintText: 'Search tasks',
                  borderColor: colorScheme.outline,
                  fontSize: 14,
                  textColor: colorScheme.onSurface,
                  hintTextColor: colorScheme.onSurfaceVariant,
                  showClearButton: true,
                  prefixIcon: exploreActivityFieldIcon(
                    context,
                    Icons.search,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      widget.taskController.reset();
                      return;
                    }
                    widget.taskController.fetchTasks(
                      query: value,
                      isRefresh: true,
                      businessId: widget.businessId,
                    );
                  },
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Obx(() {
                    final taskController = widget.taskController;

                    if (taskController.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (taskController.taskList.isEmpty) {
                      return ListView(
                        physics: const ClampingScrollPhysics(),
                        children: const [
                          EmptyState(
                            icon: Icons.search_outlined,
                            title: 'Search for activities',
                            subtitle: 'Type to find routes or events to add',
                            iconSize: 36,
                          ),
                        ],
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
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: taskController.taskList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == taskController.taskList.length) {
                            if (taskController.isPaginationLoading.value) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (!taskController.hasMore.value) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'No more results',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final item = taskController.taskList[index];
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.activityType,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(
                              Icons.add_circle,
                              color: colorScheme.primary,
                            ),
                            onTap: () {
                              widget.onAddTask(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
