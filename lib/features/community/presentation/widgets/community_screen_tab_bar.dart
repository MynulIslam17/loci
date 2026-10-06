import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';
import 'package:loci/shared/widgets/adaptive_tab_bar.dart';

/// Tab labels for the community hub (Feed, Offers, Notices, Activity).
class CommunityTabBar extends StatelessWidget {
  const CommunityTabBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  static const tabs = ['Feed', 'Offers', 'Notices', 'Activity'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: CommunityUi.tabBarBottomSpacing,
        ),
        child: AdaptiveTabBar(
          controller: controller,
          labels: tabs,
          isScrollable: true,
          style: AdaptiveTabBarStyle.underline,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

/// Pinned tab bar sliver for [NestedScrollView] when the header has finished loading.
class CommunityScreenTabBar extends StatelessWidget {
  const CommunityScreenTabBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
        pinned: true,
        toolbarHeight: 0,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            kTextTabBarHeight + CommunityUi.tabBarBottomSpacing,
          ),
          child: CommunityTabBar(controller: controller),
        ),
      ),
    );
  }
}
