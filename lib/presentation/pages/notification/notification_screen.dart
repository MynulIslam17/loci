import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/notification/notification_model.dart';
import 'package:loci/presentation/controllers/notification/notification_controller.dart';
import 'package:loci/presentation/pages/notification/widgets/notification_card.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/empty_state.dart';
import 'package:loci/presentation/widgets/pagination_loading.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Scaffold(
      appBar: const CustomAppbar(title: "Notifications"),
      body: GetBuilder<NotificationController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: AppSkeleton.list(context: context, itemCount: 6),
            );
          }

          if (ctrl.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ctrl.fetchNotifications(refresh: true),
              child: LayoutBuilder(builder: (context,constraints){

                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child:    EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: "No notifications yet",
                      subtitle: "You're all caught up!",
                    ),
                  ),

                );

              })
            );
          }

          return RefreshIndicator(
            onRefresh: () => ctrl.fetchNotifications(refresh: true),
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: ctrl.notifications.length + (ctrl.isPaginationLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == ctrl.notifications.length) {
                  return const PaginationLoader();
                }
                return NotificationCard(notification: ctrl.notifications[index]);
              },
            ),
          );
        },
      ),
    );
  }
}




