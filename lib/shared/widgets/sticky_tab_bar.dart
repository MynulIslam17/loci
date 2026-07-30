import 'package:flutter/material.dart';

import '../../core/constants/app_text_style.dart';

/// Pins a [TabBar] below a scrollable header inside [NestedScrollView].
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  StickyTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
    this.height = 52,
  });

  final TabBar tabBar;
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
  required TabBar tabBar,
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

/// App-wide [TabBar] styling for sticky sent/received (or similar) tabs.
TabBar appStickyTabBar({
  required TabController controller,
  required ColorScheme colorScheme,
  required List<String> labels,
}) {
  return TabBar(
    controller: controller,
    labelStyle: AppTextStyle.textSm(weight: FontWeight.w600),
    unselectedLabelStyle: AppTextStyle.textSm(),
    labelColor: colorScheme.primary,
    unselectedLabelColor: colorScheme.onSurfaceVariant,
    indicatorColor: colorScheme.primary,
    indicatorWeight: 3,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    tabs: [for (final label in labels) Tab(text: label)],
  );
}
