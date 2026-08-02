import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/notification/presentation/controllers/notification_controller.dart';
import 'package:loci/features/notification/presentation/widgets/notification_card.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<NotificationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Notifications"),
      body: Obx(() {
        final ctrl = _controller;

        if (ctrl.showInitialShimmer && ctrl.notifications.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: AppSkeleton.list(context: context, itemCount: 6),
          );
        }

        if (ctrl.errorMessage != null && ctrl.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ctrl.fetchNotifications(refresh: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: ErrorStateWidget(
                      message: ctrl.errorMessage!,
                      onRetry: () => ctrl.fetchNotifications(refresh: true),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (ctrl.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ctrl.fetchNotifications(refresh: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: "No notifications yet",
                      subtitle: "You're all caught up!",
                    ),
                  ),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.fetchNotifications(refresh: true),
          child: ListView.builder(
            controller: _controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount:
                ctrl.notifications.length + (ctrl.isPaginationLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == ctrl.notifications.length) {
                return const PaginationLoader();
              }
              return NotificationCard(notification: ctrl.notifications[index]);
            },
          ),
        );
      }),
    );
  }
}
