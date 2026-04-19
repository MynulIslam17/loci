import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_event_list_controller.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/event_edit_card.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/raffles_edit_card.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/route_edit_card.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/constants/app_text_style.dart';
import '../../controllers/event/event_list_controller.dart';
import '../../controllers/explore_acitivity/business_route_list_controller.dart';
import '../../controllers/routes/route_list_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ExploreActivityScreen extends StatefulWidget {
  const ExploreActivityScreen({super.key});

  @override
  State<ExploreActivityScreen> createState() => _ExploreActivityScreenState();
}

class _ExploreActivityScreenState extends State<ExploreActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  //---get x controller
  final eventListController = Get.find<BusinessEventListController>();
  final routeListController = Get.find<BusinessRouteListController>();

  late final String businessId;
  late final String businessName;

  bool _isFetchingMore = false;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    final args = Get.arguments as Map<String, dynamic>?;

    businessId = args?["businessId"] ?? "";
    businessName = args?["businessName"] ?? "";

    eventListController.fetchEvents(isRefresh: true, businessId: businessId);

    //===== call data during tab switch
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;

      if (_tabController.index == 0 && eventListController.eventList.isEmpty) {
        eventListController.fetchEvents(
          isRefresh: true,
          businessId: businessId,
        );
      } else if (_tabController.index == 1 &&
          routeListController.routeList.isEmpty) {
        routeListController.fetchRoutes(
          isRefresh: true,
          businessId: businessId,
        );
      }
    });
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
      appBar: const CustomAppbar(title: "Explore Activities"),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Search + Button + Title — hides on scroll
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    borderColor: colorScheme.outline,
                    hintText: "Explore Activities",
                    hintTextColor: colorScheme.onSurfaceVariant,
                    textColor: colorScheme.onSurface,
                    suffixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    backgroundColor: colorScheme.primary,
                    onPressed: () {
                      //TODO : go to crate activity page
                      Get.toNamed(
                        AppRoutes.createActivity,
                        arguments: {
                          "businessName": businessName,
                          "businessId": businessId,
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "Create New Activity",
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Explore Activities",
                    style: AppTextStyle.textLg(
                      weight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track ongoing activities like events, routes or raffles",
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // TabBar — stays pinned at top while scrolling
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurface,
                  indicatorColor: colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Events"),
                    Tab(text: "Routes"),
                    Tab(text: "Raffles"),
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
            // 1. Events Tab
            GetBuilder<BusinessEventListController>(
              builder: (controller) => _buildTabContent(
                _eventsTab(),
                isLoading: controller.isLoading,
                isPaginationLoading: controller.isPaginationLoading,
                onRefresh: () => controller.fetchEvents(businessId: businessId, isRefresh: true),
                onLoadMore: () => controller.loadMoreEvents(businessId: businessId),
              ),
            ),

            // 2. Routes Tab
            GetBuilder<BusinessRouteListController>(
              builder: (controller) => _buildTabContent(
                _routesTab(),
                isLoading: controller.isLoading,
                isPaginationLoading: controller.isPaginationLoading,
                onRefresh: () => controller.fetchRoutes(businessId: businessId, isRefresh: true),
                onLoadMore: () => controller.loadMoreRoutes(businessId: businessId),
              ),
            ),

            // 3. Raffles Tab
            _buildTabContent(
              _rafflesTab(),
              isLoading: false,
              isPaginationLoading: false,
              onRefresh: () {},
              onLoadMore: () {},
            ),
          ],
        )
      ),
    );
  }

  // Wraps each tab's SliverList inside a CustomScrollView with overlap handling
  Widget _buildTabContent(
    Widget sliver, {
    required VoidCallback onRefresh,
    required VoidCallback onLoadMore,
    required bool isLoading,
    required bool isPaginationLoading,
  }) {
    return Builder(
      builder: (context) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.extentAfter < 300) {
                if (!isLoading && !isPaginationLoading) {
                  onLoadMore();
                }
              }
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
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

  Widget _eventsTab() {
    return GetBuilder<BusinessEventListController>(
      builder: (controller) {
        // ===== LOADING
        if (controller.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // ===== ERROR
        if (controller.errorMessage != null) {
          return SliverFillRemaining(
            child: Center(child: Text(controller.errorMessage!)),
          );
        }

        // ===== EMPTY
        if (controller.eventList.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text("No events found")),
          );
        }

        // ===== LIST
        return SliverList.separated(
          itemCount: controller.eventList.length + 1,
          itemBuilder: (context, index) {
            //  Last item = loader
            if (index == controller.eventList.length) {
              if (controller.isPaginationLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!controller.hasMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text("No more events")),
                );
              }
              return const SizedBox.shrink(); // nothing to show
            }

            // Normal items

            final event = controller.eventList[index];
            return EventEditCard(
              imageUrl: event.coverImage,
              title: event.title,
              description: event.description,
              dateTime: event.date,
              location: event.location,
              attendance:
                  "${event.goingCount} going / ${event.maxAttendees} max",
              organizerName: event.organizerName,
              onEditInfo: () => Get.toNamed(
                AppRoutes.editEvent,
                arguments: {"eventId": event.id},
              ),
              onViewDetails: () => Get.toNamed(
                AppRoutes.viewEvent,
                arguments: {"eventId": event.id, "title": event.title},
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 10),
        );
      },
    );
  }

  Widget _routesTab() {
    final colorScheme = context.colorScheme;
    return GetBuilder<BusinessRouteListController>(
      builder: (controller) {
        // ===== LOADING
        if (controller.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // ===== ERROR
        if (controller.errorMessage != null) {
          return SliverFillRemaining(
            child: Center(child: Text(controller.errorMessage!)),
          );
        }

        // ===== EMPTY
        if (controller.routeList.isEmpty) {
          return SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  "No routes found",
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.fetchRoutes(
                    businessId: businessId,
                    isRefresh: true,
                  ),
                  child: const Text("Try Again"),
                ),
              ],
            ),
          );
        }

        // ===== LIST
        return SliverList.separated(
          itemCount: controller.routeList.length + 1,
          itemBuilder: (context, index) {
            //  Last item = loader
            if (index == controller.routeList.length) {
              if (controller.isPaginationLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!controller.hasMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text("No more routes")),
                );
              }
              return const SizedBox.shrink(); // nothing to show
            }

            final route = controller.routeList[index];
            return RouteEditCard(
              imageUrl: route.banner,
              title: route.title,
              description: route.details,
              location: route.location,
              openingTime: route.openingTime,
              availabilityType: route.availabilityType,
              isPublic: route.isRoutePublic,
              onEdit: () => Get.toNamed(
                AppRoutes.editRoutes,
                arguments: {"routeName": route.title, "routeId": route.routeId},
              ),
              onView: () => Get.toNamed(
                AppRoutes.viewRoutes,
                arguments: {"routeName": route.title, "routeId": route.routeId},
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 10),
        );
      },
    );
  }

  Widget _rafflesTab() {
    return SliverList.separated(
      itemCount: 5,
      itemBuilder: (context, index) => RaffleEditCard(
        title: "Coffee Lovers Bundle",
        description: "Check in to 3 or more stops to enter. Win a bundle of coffee beans and best beer to drink of your life.",
        endDate: "Jan 26, 2026", //date range
        prizeText: "Premium Coffee Bundle (\$200 value)",//bundle prize name
        organizerName: "Crawl Events Co.",
        imageUrl: "https://picsum.photos/seed/raffle$index/400/300",
        onEdit: () => Get.toNamed(
          AppRoutes.editRaffles,
          arguments: {
            "title": "Edit Raffles",
            "businessId": businessId,
          },
        ),
        onView: () {
          // Navigate to details
        },
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }
}

//---- sticky tab bar work as header
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  _StickyTabBarDelegate(this.tabBar, {required this.color});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: color, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) => false;
}
