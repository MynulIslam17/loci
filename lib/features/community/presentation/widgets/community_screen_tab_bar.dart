import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';

class CommunityScreenTabBar extends StatelessWidget {
  const CommunityScreenTabBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  static const _tabs = ['Feed', 'Offers', 'Notices', 'Activity'];

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
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: CommunityUi.tabBarBottomSpacing,
            ),
            child: TabBar(
              controller: controller,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: colors.primary,
              unselectedLabelColor: colors.onSurfaceVariant,
              indicatorColor: colors.primary,
              dividerColor: colors.outlineVariant.withValues(alpha: 0.35),
              labelStyle: AppTextStyle.textSm(weight: FontWeight.w600),
              unselectedLabelStyle: AppTextStyle.textSm(
                weight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
              tabs: [for (final label in _tabs) Tab(text: label)],
            ),
          ),
        ),
      ),
    );
  }
}
