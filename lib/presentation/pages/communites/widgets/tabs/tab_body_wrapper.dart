import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/controllers/comment/announcement_controller.dart';
import 'package:loci/presentation/widgets/pagination_loading.dart';

class TabBodyWrapper extends StatelessWidget {
  final Widget Function() builder;

  const TabBodyWrapper({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GetBuilder<AnnouncementController>(
        builder: (controller) => RefreshIndicator(
          onRefresh: () => controller.refreshAnnouncements(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200 &&
                    controller.hasMore &&
                    !controller.isPaginationLoading) {
                  controller.fetchMoreAnnouncements();
                }
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                if (controller.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  SliverToBoxAdapter(child: builder()),
                  if (controller.isPaginationLoading)
                    const SliverToBoxAdapter(
                      child: PaginationLoader(size: 18, padding: 10),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
