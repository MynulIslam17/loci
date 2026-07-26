import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/raffles/data/models/raffles_model.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffles_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/event_edit_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/raffles_edit_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/route_edit_card.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/event/presentation/controllers/event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_list_controller.dart';
import 'package:loci/features/routes/presentation/controllers/route_list_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/error_state.dart';

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
  final raffleListController = Get.find<BusinessRafflesListController>();

  late final String businessId;
  late final String businessName;
  int _activeTabIndex = 0;

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
      if (_tabController.indexIsChanging ||
          _tabController.animation?.value == _tabController.index) {
        if (_tabController.index != _activeTabIndex) {
          // Only run logic if the index has actually changed
          _activeTabIndex = _tabController.index;

          // Fetch data based on the new index
          _fetchDataForTab(_activeTabIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to call api on tab switch
  void _fetchDataForTab(int index) {
    if (index == 0 && eventListController.eventList.isEmpty) {
      eventListController.fetchEvents(isRefresh: true, businessId: businessId);
    } else if (index == 1 && routeListController.routeList.isEmpty) {
      routeListController.fetchRoutes(isRefresh: true, businessId: businessId);
    } else if (index == 2 && raffleListController.raffleList.isEmpty) {
      raffleListController.fetchRaffles(
        isRefresh: true,
        businessId: businessId,
      );
    }
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
            Obx(() {
              final controller = Get.find<BusinessEventListController>();
              return _buildTabContent(
                _eventsTab(),
                isLoading: controller.isLoading.value,
                isPaginationLoading: controller.isPaginationLoading.value,
                onRefresh: () => controller.fetchEvents(
                  businessId: businessId,
                  isRefresh: true,
                ),
                onLoadMore: () =>
                    controller.loadMoreEvents(businessId: businessId),
              );
            }),

            // 2. Routes Tab
            Obx(() {
              final controller = Get.find<BusinessRouteListController>();
              return _buildTabContent(
                _routesTab(),
                isLoading: controller.isLoading.value,
                isPaginationLoading: controller.isPaginationLoading.value,
                onRefresh: () => controller.fetchRoutes(
                  businessId: businessId,
                  isRefresh: true,
                ),
                onLoadMore: () =>
                    controller.loadMoreRoutes(businessId: businessId),
              );
            }),

            // 3. Raffles Tab
            Obx(() {
              final controller = Get.find<BusinessRafflesListController>();
              return _buildTabContent(
                _rafflesTab(),
                isLoading: controller.isLoading.value,
                isPaginationLoading: controller.isPaginationLoading.value,
                onRefresh: () => controller.fetchRaffles(
                  businessId: businessId,
                  isRefresh: true,
                ),
                onLoadMore: () =>
                    controller.loadMoreRaffles(businessId: businessId),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Wraps each tab's SliverList inside raffles CustomScrollView with overlap handling
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
    return Obx(() {
      final controller = Get.find<BusinessEventListController>();
      // ===== LOADING
      if (controller.isLoading.value && controller.eventList.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // ===== ERROR
      if (controller.errorMessage.value != null &&
          controller.eventList.isEmpty) {
        return SliverFillRemaining(
          child: ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () =>
                controller.fetchEvents(businessId: businessId, isRefresh: true),
          ),
        );
      }

      // ===== EMPTY
      if (!controller.isLoading.value && controller.eventList.isEmpty) {
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
            if (controller.isPaginationLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (!controller.hasMore.value) {
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
            attendance: "${event.goingCount} going / ${event.maxAttendees} max",
            organizerName: event.organizerName,
            onEditInfo: () async {
              final result = await Get.toNamed(
                AppRoutes.editEvent,
                arguments: {"eventId": event.id},
              );

              //reload data after update
              if (result == true) {
                controller.fetchEvents(isRefresh: true, businessId: businessId);
              }
            },
            onViewDetails: () => Get.toNamed(
              AppRoutes.viewEvent,
              arguments: {"eventId": event.id, "title": event.title},
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
      );
    });
  }

  Widget _routesTab() {
    final colorScheme = context.colorScheme;
    return Obx(() {
      final controller = Get.find<BusinessRouteListController>();
      // ===== LOADING
      if (controller.isLoading.value && controller.routeList.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // ===== ERROR
      if (controller.errorMessage.value != null) {
        return SliverFillRemaining(
          child: ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () =>
                controller.fetchRoutes(businessId: businessId, isRefresh: true),
          ),
        );
      }

      // ===== EMPTY
      if (!controller.isLoading.value && controller.routeList.isEmpty) {
        return SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route, size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                "No routes found",
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
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
            if (controller.isPaginationLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (!controller.hasMore.value) {
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
            onEdit: () async {
              final result = await Get.toNamed(
                AppRoutes.editRoutes,
                arguments: {"routeName": route.title, "routeId": route.routeId},
              );

              //reload data after update
              if (result == true) {
                await controller.fetchRoutes(
                  businessId: businessId,
                  isRefresh: true,
                );
              }
            },
            onView: () => Get.toNamed(
              AppRoutes.viewRoutes,
              arguments: {"routeName": route.title, "routeId": route.routeId},
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
      );
    });
  }

  Widget _rafflesTab() {
    return Obx(() {
      final controller = Get.find<BusinessRafflesListController>();
      // 1. INITIAL LOADING STATE:

      if (controller.isLoading.value && controller.raffleList.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // 2. ERROR STATE:
      if (controller.errorMessage.value != null &&
          controller.raffleList.isEmpty) {
        return SliverFillRemaining(
          child: ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.fetchRaffles(
              businessId: businessId,
              isRefresh: true,
            ),
          ),
        );
      }

      // 3. EMPTY STATE:
      if (!controller.isLoading.value && controller.raffleList.isEmpty) {
        return const SliverFillRemaining(
          child: Center(child: Text("No raffles found")),
        );
      }

      // 4. DATA LIST:
      return SliverList.separated(
        // We add +1 to the count to represent the "Footer" (either raffles loader or raffles "No more" message)
        itemCount: controller.raffleList.length + 1,
        itemBuilder: (context, index) {
          // 5. FOOTER LOGIC (Pagination & End of List):

          if (index == controller.raffleList.length) {
            // Show raffles spinner if the controller is currently fetching the next page.
            if (controller.isPaginationLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            // Show raffles message if we have reached the end of the server's data.
            if (!controller.hasMore.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text("No more raffles")),
              );
            }

            // Otherwise, show nothing (this happens while the user hasn't scrolled to the bottom yet).
            return const SizedBox.shrink();
          }

          // 6. NORMAL LIST ITEM:
          final raffle = controller.raffleList[index];
          return RaffleEditCard(
            title: raffle.title,
            description: raffle.description,
            dateRange: _dateRange(raffle),
            prizeText: raffle.bundleName,
            imageUrl: raffle.banner,
            organizerName: raffle.organizerName,
            onEdit: () async {
              final result = await Get.toNamed(
                AppRoutes.editRaffles,
                arguments: {"raffleId": raffle.id},
              );
              if (result == true) {
                await controller.fetchRaffles(
                  businessId: businessId,
                  isRefresh: true,
                );
              }
            },
            onView: () {
              Get.toNamed(
                AppRoutes.viewRaffles,
                arguments: {"raffleId": raffle.id, "rafflesName": raffle.title},
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
      );
    });
  }

  //--------------- date range helper-------------------------------
  String _dateRange(RaffleModel model) {
    final startDate = DateTime.parse(model.startDate).toLocal();
    final endDate = DateTime.parse(model.endDate).toLocal();

    return "${DateParserHelper.shortDate(startDate)} - ${DateParserHelper.shortDate(endDate)}";
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
