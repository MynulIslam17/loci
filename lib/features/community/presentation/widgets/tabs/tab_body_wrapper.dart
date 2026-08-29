import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_tab_empty_state.dart';
import 'package:loci/features/community/presentation/widgets/community_tab_shimmers.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';
import 'package:loci/features/main_nav/presentation/widgets/ios_glass_bottom_nav_bar.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
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
        final isRefreshing = controller.isRefreshingFor(tabType);
        final hasLoaded = controller.hasLoadedFor(tabType);
        final items = controller.announcementsFor(tabType);
        final error = controller.errorFor(tabType);
        final colors = Theme.of(context).colorScheme;

        final showListShimmer = error == null && isLoading && !hasLoaded;
        final showError = hasLoaded && error != null && items.isEmpty;
        final showEmpty = hasLoaded &&
            !isLoading &&
            !isRefreshing &&
            items.isEmpty &&
            error == null;

        // The pinned tab bar always absorbs overlap (see [CommunityScreenBody]),
        // so every scroll state — including the loading shimmer — must inject it
        // back, otherwise content renders hidden behind the tab bar.
        final useOverlapInjector = !headerAboveList;

        return _TabScrollContent(
          tabType: tabType,
          colors: colors,
          headerAboveList: headerAboveList,
          useOverlapInjector: useOverlapInjector,
          stickyHeader: stickyHeader,
          showListShimmer: showListShimmer,
          showError: showError,
          showEmpty: showEmpty,
          error: error,
          shimmerBuilder: shimmerBuilder,
          builder: builder,
          isPaginationLoading: controller.isPaginationLoadingFor(tabType),
          isRefreshing: isRefreshing,
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
    required this.useOverlapInjector,
    required this.stickyHeader,
    required this.showListShimmer,
    required this.showError,
    required this.showEmpty,
    required this.error,
    required this.shimmerBuilder,
    required this.builder,
    required this.isPaginationLoading,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    required this.canLoadMore,
    required this.isActiveTab,
  });

  final AnnouncementType tabType;
  final ColorScheme colors;
  final bool headerAboveList;
  final bool useOverlapInjector;
  final Widget? stickyHeader;
  final bool showListShimmer;
  final bool showError;
  final bool showEmpty;
  final String? error;
  final Widget Function(BuildContext context)? shimmerBuilder;
  final Widget Function() builder;
  final bool isPaginationLoading;
  final bool isRefreshing;
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
    return AdaptiveRefresh(
      onRefresh: onRefresh,
        child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!isActiveTab) return false;
          // Ignore nested scrollables (e.g. business mention results list)
          // so NestedScrollView / feed pagination don't steal the gesture.
          if (notification.depth > 0) return false;
          if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200 &&
                canLoadMore &&
                !isPaginationLoading &&
                !isRefreshing) {
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
              if (useOverlapInjector)
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),
              // Keep the real search bar / composer visible even while the
              // list loads, so it never gets swapped for a skeleton on tab
              // switch. Only errors take over the whole tab.
              if (!headerAboveList && stickyHeader != null && !showError)
                SliverToBoxAdapter(child: stickyHeader!),
              if (showListShimmer)
                SliverToBoxAdapter(
                  child: _tabListShimmer(context),
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
              else if (showEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: CommunityTabEmptyState(type: tabType),
                )
              else ...[
                SliverToBoxAdapter(child: builder()),
                if (isPaginationLoading)
                  const SliverToBoxAdapter(
                    child: PaginationLoader(size: 18, padding: 10),
                  ),
              ],
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom:
                      IosGlassBottomNavBar.overlayBottomInset(context) + 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// List skeleton only. The real sticky header (search bar / composer) is
  /// rendered above this by [_buildScrollView], so we never shimmer it.
  Widget _tabListShimmer(BuildContext context) {
    final listShimmer = shimmerBuilder != null
        ? shimmerBuilder!(context)
        : TabBodyWrapper.defaultShimmerFor(tabType);

    // When there's no sticky header above (or it's hosted outside the scroll
    // view), keep the top spacing so the shimmer doesn't butt against the tab
    // bar.
    if (stickyHeader != null && !headerAboveList) return listShimmer;

    return Padding(
      padding: const EdgeInsets.only(top: CommunityUi.stickyHeaderTop),
      child: listShimmer,
    );
  }
}
