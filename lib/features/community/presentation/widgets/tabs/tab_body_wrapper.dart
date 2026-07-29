import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_tab_empty_state.dart';
import 'package:loci/features/community/presentation/widgets/community_tab_shimmers.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

class TabBodyWrapper extends StatelessWidget {
  const TabBodyWrapper({
    super.key,
    required this.tabType,
    required this.builder,
    this.shimmerBuilder,
    this.stickyHeader,
  });

  final AnnouncementType tabType;
  final Widget Function() builder;
  final Widget Function(BuildContext context)? shimmerBuilder;
  final Widget? stickyHeader;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Obx(() {
        final controller = Get.find<AnnouncementController>();
        controller.revisionFor(tabType).value;
        controller.announcementMap.length;

        final isLoading = controller.isLoadingFor(tabType);
        final hasLoaded = controller.hasLoadedFor(tabType);
        final items = controller.announcementsFor(tabType);
        final error = controller.errorFor(tabType);

        final showTabShimmer = !hasLoaded && error == null;
        final showError = hasLoaded && error != null && items.isEmpty;
        final showEmpty =
            hasLoaded && !isLoading && items.isEmpty && error == null;

        return RefreshIndicator(
          onRefresh: () => controller.refreshTabWithCommunityMeta(tabType),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (controller.currentType.value != tabType) return false;
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200 &&
                    controller.hasMoreFor(tabType) &&
                    !controller.isPaginationLoadingFor(tabType)) {
                  controller.fetchMoreAnnouncements(type: tabType);
                }
              }
              return false;
            },
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
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
                  if (showTabShimmer)
                    SliverToBoxAdapter(
                      child: shimmerBuilder != null
                          ? shimmerBuilder!(context)
                          : _defaultShimmerFor(tabType),
                    )
                  else if (showError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ErrorStateWidget(
                          message: error,
                          onRetry: () => controller.fetchAnnouncements(
                            type: tabType,
                            isRefresh: true,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(child: builder()),
                    if (showEmpty)
                      SliverToBoxAdapter(
                        child: CommunityTabEmptyState(type: tabType),
                      ),
                    if (controller.isPaginationLoadingFor(tabType))
                      const SliverToBoxAdapter(
                        child: PaginationLoader(size: 18, padding: 10),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  static Widget _defaultShimmerFor(AnnouncementType type) {
    return switch (type) {
      AnnouncementType.question => const CommunityFeedListShimmer(),
      AnnouncementType.offer => const CommunityOffersListShimmer(),
      AnnouncementType.notice => const CommunityNoticesListShimmer(),
      AnnouncementType.activity => const CommunityActivityListShimmer(),
    };
  }
}
