import 'package:flutter/material.dart';

import 'adaptive_tab_bar.dart';

/// Pins a [tabBar] below a scrollable header inside [NestedScrollView].
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  StickyTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
    this.height = 52,
  });

  final Widget tabBar;
  final Color backgroundColor;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: Align(alignment: Alignment.center, child: tabBar),
    );
  }

  @override
  bool shouldRebuild(StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor ||
        height != oldDelegate.height;
  }
}

/// Returns a pinned [SliverPersistentHeader] for use in [NestedScrollView].
SliverPersistentHeader stickyTabBarSliver({
  required Widget tabBar,
  required Color backgroundColor,
  double height = 52,
}) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: StickyTabBarDelegate(
      tabBar: tabBar,
      backgroundColor: backgroundColor,
      height: height,
    ),
  );
}

/// App-wide adaptive tab bar for sticky sent/received (or similar) tabs.
Widget appStickyTabBar({
  required TabController controller,
  required ColorScheme colorScheme,
  required List<String> labels,
  bool isScrollable = false,
}) {
  return AdaptiveTabBar(
    controller: controller,
    labels: labels,
    isScrollable: isScrollable,
    style: AdaptiveTabBarStyle.underline,
    padding: const EdgeInsets.symmetric(horizontal: 16),
  );
}
