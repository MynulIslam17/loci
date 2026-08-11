import 'package:flutter/material.dart';

/// Nested scroll + refresh wrapper shared by explore-activity tabs.
class ExploreActivityTabScroll extends StatelessWidget {
  const ExploreActivityTabScroll({
    super.key,
    required this.sliver,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isRefreshing,
    required this.isPaginationLoading,
  });

  final Widget sliver;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final bool isRefreshing;
  final bool isPaginationLoading;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.extentAfter < 300 &&
                  !isLoading &&
                  !isRefreshing &&
                  !isPaginationLoading) {
                onLoadMore();
              }
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 20),
                  sliver: sliver,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
