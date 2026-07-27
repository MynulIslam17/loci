import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/data/models/task_model.dart';
import 'package:loci/features/explore_activity/presentation/controllers/task_controller.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/empty_state.dart';

void showCreateActivityTaskSheet({
  required BuildContext context,
  required String businessId,
  required void Function(TaskModel task) onAddTask,
}) {
  final taskController = Get.find<TaskController>();
  taskController.reset();

  showModalBottomSheet<void>(
    backgroundColor: context.colorScheme.surface,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final colorScheme = sheetContext.colorScheme;

      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Requirement',
                  style: AppTextStyle.textLg(
                    weight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: Icon(Icons.cancel, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Search tasks',
              borderColor: colorScheme.outline,
              fontSize: 14,
              textColor: colorScheme.onSurface,
              hintTextColor: colorScheme.onSurfaceVariant,
              suffixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  taskController.fetchTasks(
                    query: value,
                    isRefresh: true,
                    businessId: businessId,
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.4,
              ),
              child: Obx(() {
                if (taskController.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (taskController.taskList.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_outlined,
                    title: 'Search for activities',
                    subtitle: 'Type to find routes or events to add',
                    iconSize: 40,
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotify) {
                    if (scrollNotify.metrics.pixels >=
                        scrollNotify.metrics.maxScrollExtent - 200) {
                      if (!taskController.isPaginationLoading.value &&
                          taskController.hasMore.value) {
                        taskController.loadMoreTasks(businessId: businessId);
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
                        title: Text(item.title),
                        subtitle: Text(item.activityType),
                        trailing: Icon(
                          Icons.add_circle,
                          color: colorScheme.primary,
                        ),
                        onTap: () {
                          onAddTask(item);
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      );
    },
  );
}
