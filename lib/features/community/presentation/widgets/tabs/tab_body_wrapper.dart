import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

class TabBodyWrapper extends StatelessWidget {
  final Widget Function() builder;
  final Widget Function(BuildContext context)? shimmerBuilder;
  final Widget? stickyHeader;

  const TabBodyWrapper({
    super.key,
    required this.builder,
    this.shimmerBuilder,
    this.stickyHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Obx(() {
        final controller = Get.find<AnnouncementController>();
        return RefreshIndicator(
          onRefresh: () => controller.refreshAnnouncements(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200 &&
                    controller.hasMore &&
                    !controller.isPaginationLoading.value) {
                  controller.fetchMoreAnnouncements();
                }
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),
                if (stickyHeader != null)
                  SliverToBoxAdapter(child: stickyHeader!),
                if (controller.isLoading.value)
                  SliverToBoxAdapter(
                    child: shimmerBuilder != null
                        ? shimmerBuilder!(context)
                        : AppSkeleton.list(context: context, itemCount: 4),
                  )
                else ...[
                  SliverToBoxAdapter(child: builder()),
                  if (controller.isPaginationLoading.value)
                    const SliverToBoxAdapter(
                      child: PaginationLoader(size: 18, padding: 10),
                    ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
