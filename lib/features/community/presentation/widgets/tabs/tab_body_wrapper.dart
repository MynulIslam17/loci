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
    this.headerAboveList = false,
  });

  final AnnouncementType tabType;
  final Widget Function() builder;
  final Widget Function(BuildContext context)? shimmerBuilder;
  final Widget? stickyHeader;

  /// Search/input fixed above the list so the keyboard resizes the list, not
  /// the header.
  final bool headerAboveList;

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
        final colors = Theme.of(context).colorScheme;

        final showListShimmer = error == null && (!hasLoaded || isLoading);
        final showError = hasLoaded && error != null && items.isEmpty;
        final showEmpty =
            hasLoaded && !isLoading && items.isEmpty && error == null;

        return _TabScrollContent(
          tabType: tabType,
          colors: colors,
          headerAboveList: headerAboveList,
          stickyHeader: stickyHeader,
          showListShimmer: showListShimmer,
          showError: showError,
          showEmpty: showEmpty,
          error: error,
          shimmerBuilder: shimmerBuilder,
          builder: builder,
          isPaginationLoading: controller.isPaginationLoadingFor(tabType),
          onRefresh: () => controller.refreshTabWithCommunityMeta(tabType),
          onRetry: () => controller.fetchAnnouncements(
            type: tabType,
            isRefresh: true,
          ),
          onLoadMore: () => controller.fetchMoreAnnouncements(type: tabType),
          canLoadMore: controller.hasMoreFor(tabType),
          isActiveTab: controller.currentType.value == tabType,
        );
      }),
    );
  }

  static Widget defaultShimmerFor(AnnouncementType type) {
    return switch (type) {
      AnnouncementType.question => const CommunityFeedListShimmer(),
      AnnouncementType.offer => const CommunityOffersListShimmer(),
      AnnouncementType.notice => const CommunityNoticesListShimmer(),
      AnnouncementType.activity => const CommunityActivityListShimmer(),
    };
  }
}

class _TabScrollContent extends StatelessWidget {
  const _TabScrollContent({
    required this.tabType,
    required this.colors,
    required this.headerAboveList,
    required this.stickyHeader,
    required this.showListShimmer,
    required this.showError,
    required this.showEmpty,
    required this.error,
    required this.shimmerBuilder,
    required this.builder,
    required this.isPaginationLoading,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    required this.canLoadMore,
    required this.isActiveTab,
  });

  final AnnouncementType tabType;
  final ColorScheme colors;
  final bool headerAboveList;
  final Widget? stickyHeader;
  final bool showListShimmer;
  final bool showError;
  final bool showEmpty;
  final String? error;
  final Widget Function(BuildContext context)? shimmerBuilder;
  final Widget Function() builder;
  final bool isPaginationLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final bool canLoadMore;
  final bool isActiveTab;

  @override
  Widget build(BuildContext context) {
    final scrollView = _buildScrollView(context);

    if (headerAboveList && stickyHeader != null) {
      return ColoredBox(
        color: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            stickyHeader!,
            Expanded(child: scrollView),
          ],
        ),
      );
    }

    return scrollView;
  }

  Widget _buildScrollView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!isActiveTab) return false;
          if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200 &&
                canLoadMore &&
                !isPaginationLoading) {
              onLoadMore();
            }
          }
          return false;
        },
        child: ColoredBox(
          color: colors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (!headerAboveList)
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),
              if (!headerAboveList && stickyHeader != null)
                SliverToBoxAdapter(child: stickyHeader!),
              if (showListShimmer)
                SliverToBoxAdapter(
                  child: shimmerBuilder != null
                      ? shimmerBuilder!(context)
                      : TabBodyWrapper.defaultShimmerFor(tabType),
                )
              else if (showError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: ErrorStateWidget(
                      message: error ?? 'Something went wrong',
                      onRetry: onRetry,
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(child: builder()),
                if (showEmpty)
                  SliverToBoxAdapter(
                    child: CommunityTabEmptyState(type: tabType),
                  ),
                if (isPaginationLoading)
                  const SliverToBoxAdapter(
                    child: PaginationLoader(size: 18, padding: 10),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
