import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffles_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_events_tab.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_header.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffles_tab.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_routes_tab.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

class ExploreActivityScreen extends StatefulWidget {
  const ExploreActivityScreen({super.key});

  @override
  State<ExploreActivityScreen> createState() => _ExploreActivityScreenState();
}

class _ExploreActivityScreenState extends State<ExploreActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _eventListController = Get.find<BusinessEventListController>();
  final _routeListController = Get.find<BusinessRouteListController>();
  final _raffleListController = Get.find<BusinessRafflesListController>();

  late final String businessId;
  late final String businessName;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    final args = Get.arguments as Map<String, dynamic>?;
    businessId = args?['businessId'] ?? '';
    businessName = args?['businessName'] ?? '';

    _loadTab(0);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _loadTab(_tabController.index);
    });
  }

  void _loadTab(int index) {
    switch (index) {
      case 0:
        _eventListController.loadIfNeeded(businessId);
      case 1:
        _routeListController.loadIfNeeded(businessId);
      case 2:
        _raffleListController.loadIfNeeded(businessId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: 'Explore Activities'),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: ExploreActivityHeader(
              businessId: businessId,
              businessName: businessName,
            ),
          ),
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurface,
                  indicatorColor: colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Events'),
                    Tab(text: 'Routes'),
                    Tab(text: 'Raffles'),
                  ],
                ),
                color: colorScheme.surface,
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            ExploreActivityEventsTab(businessId: businessId),
            ExploreActivityRoutesTab(businessId: businessId),
            ExploreActivityRafflesTab(businessId: businessId),
          ],
        ),
      ),
    );
  }
}
