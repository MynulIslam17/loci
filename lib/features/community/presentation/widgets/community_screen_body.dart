import 'package:flutter/material.dart';
import 'package:loci/features/community/presentation/controllers/community_screen_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_screen_header.dart';
import 'package:loci/features/community/presentation/widgets/community_screen_tab_bar.dart';
import 'package:loci/features/community/presentation/widgets/community_screen_tab_content.dart';

class CommunityScreenBody extends StatelessWidget {
  const CommunityScreenBody({
    super.key,
    required this.screen,
    required this.tabController,
    required this.searchController,
  });

  final CommunityScreenController screen;
  final TabController tabController;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (_, _) => [
        CommunityScreenHeader(
          role: screen.role,
          communityName: screen.communityName,
        ),
        CommunityScreenTabBar(controller: tabController),
      ],
      body: CommunityScreenTabContent(
        screen: screen,
        tabController: tabController,
        searchController: searchController,
      ),
    );
  }
}
