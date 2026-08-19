import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffles_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/utils/explore_activity_search_focus.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_events_tab.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_header.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffles_tab.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_routes_tab.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

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

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final ExploreActivitySearchFocus _searchFocus;
  Timer? _searchDebounce;

  // Preserves separate search query for each tab: [0: Events, 1: Routes, 2: Raffles]
  final List<String> _tabSearchQueries = ['', '', ''];

  late final String businessId;
  late final String businessName;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    final args = Get.arguments as Map<String, dynamic>?;
    businessId = args?['businessId'] ?? '';
    businessName = args?['businessName'] ?? '';

    _searchFocus = ExploreActivitySearchFocus(_searchFocusNode);

    _loadTab(0);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _searchDebounce?.cancel();

      // Sync search field with the active tab's stored query
      final tabQuery = _tabSearchQueries[_tabController.index];
      if (_searchController.text != tabQuery) {
        _searchController.text = tabQuery;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: tabQuery.length),
        );
      }

      setState(() {});
      _loadTab(_tabController.index);
    });
  }

  String get _searchHint {
    switch (_tabController.index) {
      case 0:
        return 'Search events';
      case 1:
        return 'Search routes';
      case 2:
        return 'Search raffles';
      default:
        return 'Search activities';
    }
  }

  void _onSearchChanged(String query) {
    _tabSearchQueries[_tabController.index] = query;
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      _applySearchToTab(_tabController.index, query);
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        _applySearchToTab(_tabController.index, query);
      });
    }
  }

  void _submitSearch(String query) {
    _tabSearchQueries[_tabController.index] = query;
    _searchDebounce?.cancel();
    _applySearchToTab(_tabController.index, query);
  }

  void _applySearchToTab(int index, String query) {
    switch (index) {
      case 0:
        _eventListController.applySearch(businessId: businessId, query: query);
      case 1:
        _routeListController.applySearch(businessId: businessId, query: query);
      case 2:
        _raffleListController.applySearch(businessId: businessId, query: query);
    }
  }

  void _loadTab(int index) {
    final search = _tabSearchQueries[index].trim();
    switch (index) {
      case 0:
        _eventListController.loadIfNeeded(businessId, search: search);
      case 1:
        _routeListController.loadIfNeeded(businessId, search: search);
      case 2:
        _raffleListController.loadIfNeeded(businessId, search: search);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: 'Explore Activities'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: CustomTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (v) => _submitSearch(v),
              showClearButton: true,
              onClear: () {
                _searchDebounce?.cancel();
                _tabSearchQueries[_tabController.index] = '';
                _searchController.clear();
                _applySearchToTab(_tabController.index, '');
              },
              borderColor: colorScheme.outline,
              hintText: _searchHint,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              suffixIcon: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _submitSearch(_searchController.text),
                child: Icon(
                  Icons.search,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: ExploreActivityHeader(
              businessId: businessId,
              businessName: businessName,
              searchFocus: _searchFocus,
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
            ExploreActivityEventsTab(
              businessId: businessId,
              searchFocus: _searchFocus,
            ),
            ExploreActivityRoutesTab(
              businessId: businessId,
              searchFocus: _searchFocus,
            ),
            ExploreActivityRafflesTab(
              businessId: businessId,
              searchFocus: _searchFocus,
            ),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }
}
