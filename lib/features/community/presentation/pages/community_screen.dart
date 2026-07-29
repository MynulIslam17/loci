import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/controllers/community_screen_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_screen_body.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

/// Community hub (feed, offers, notices, activity).
///
/// Data flow: UI → [CommunityScreenController] → feature controllers
/// → [CommunityService] → [CommunityRepository] → API.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    super.key,
    this.role,
    this.communityId,
    this.communityName,
  });

  final CommunityRole? role;
  final String? communityId;
  final String? communityName;

  static const _controllerTag = 'community_screen';

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final CommunityScreenController _screen;
  late final TabController _tabController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _screen = Get.put(
      CommunityScreenController(),
      tag: CommunityScreen._controllerTag,
    );
    _screen.bind(
      role: widget.role,
      communityId: widget.communityId,
      communityName: widget.communityName,
    );

    _tabController = TabController(
      length: CommunityScreenController.tabCount,
      vsync: this,
    );
    _searchController = TextEditingController();
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    _screen.handleTabChange(_tabController, _searchController);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    Get.delete<CommunityScreenController>(tag: CommunityScreen._controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: CustomAppbar(title: _screen.title),
      body: CommunityScreenBody(
        screen: _screen,
        tabController: _tabController,
        searchController: _searchController,
      ),
    );
  }
}
