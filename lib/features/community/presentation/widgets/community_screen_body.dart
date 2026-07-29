import 'package:flutter/material.dart';
import 'package:loci/features/community/presentation/controllers/community_screen_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_screen_header.dart';
import 'package:loci/features/community/presentation/widgets/community_screen_tab_bar.dart';
import 'package:loci/features/community/presentation/widgets/community_screen_tab_content.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';

/// Community hub scaffold body.
///
/// The sliver structure is intentionally *stable*: the header scrolls away
/// while the tab bar stays pinned, in both the loading and loaded states.
/// The header widgets render their own shimmer internally, so we never swap
/// the sliver tree (doing so made the tab bar jump between pinned/unpinned).
class CommunityScreenBody extends StatelessWidget {
  const CommunityScreenBody({
    super.key,
    required this.screen,
    required this.tabController,
    required this.searchControllers,
  });

  final CommunityScreenController screen;
  final TabController tabController;
  final List<TextEditingController> searchControllers;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        CommunityScreenHeader(
          role: screen.role,
          communityName: screen.communityName,
        ),
        CommunityScreenTabBar(controller: tabController),
      ],
      body: Padding(
        padding: CommunityUi.screenPadding,
        child: CommunityScreenTabContent(
          screen: screen,
          tabController: tabController,
          searchControllers: searchControllers,
        ),
      ),
    );
  }
}
