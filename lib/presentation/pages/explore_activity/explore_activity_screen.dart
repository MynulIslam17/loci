import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/event_edit_card.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/raffles_edit_card.dart';
import 'package:loci/presentation/pages/explore_activity/widgets/route_edit_card.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/constants/app_text_style.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                    suffixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    backgroundColor: colorScheme.primary,
                    onPressed: () => Get.toNamed(AppRoutes.createActivity),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "Create New Activity",
                          style: AppTextStyle.textSm(
                              weight: FontWeight.w600, color: colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Explore Activities",
                    style: AppTextStyle.textLg(
                        weight: FontWeight.w600, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track ongoing activities like events, routes or raffles",
                    style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
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
            _buildTabContent(_eventsTab()),
            _buildTabContent(_routesTab()),
            _buildTabContent(_rafflesTab()),
          ],
        ),
      ),
    );
  }

  // Wraps each tab's SliverList inside a CustomScrollView with overlap handling
  Widget _buildTabContent(Widget sliver) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Pushes content below the pinned TabBar
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 20),
              sliver: sliver,
            ),
          ],
        );
      },
    );
  }

  Widget _eventsTab() {
    return SliverList.separated(
      itemCount: 5,
      itemBuilder: (context, index) => EventEditCard(
        imageUrl: "assets/images/finedine.png",
        title: "Spring Pub Crawl Festival",
        description: "...",
        dateTime: "Mon, Jan 19 at 2:50 PM",
        location: "Downtown District",
        attendance: "0 going / 200 max",
        organizerName: "Crawl Events Co.",
        onEditInfo: () => Get.toNamed(
          AppRoutes.editEvent,
          arguments: {"title": "Spring Pub Crawl Edit"},
        ),
        onViewDetails: () => Get.toNamed(
          AppRoutes.viewEvent,
          arguments: {"title": "Spring Pub Crawl"},
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }

  Widget _routesTab() {
    return SliverList.separated(
      itemCount: 5,
      itemBuilder: (context, index) => RouteEditCard(
        title: "Adventure Trail ${index + 1}",
        description: "A scenic hike through the valley with breathtaking views...",
        location: "Philadelphia, PA",
        duration: "2h 30m",
        difficulty: "Moderate",
        imageUrl: "https://picsum.photos/seed/${index + 10}/400/300",
        onEdit: () => Get.toNamed(
          AppRoutes.editRoutes,
          arguments: {"title": "Routes Edit"},
        ),
        onView: () {
          Get.toNamed(AppRoutes.viewRoutes,
              arguments: {"title": "Adventure trall 1"}
          );
        },
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }

  Widget _rafflesTab() {
    return SliverList.separated(
      itemCount: 5,
      itemBuilder: (context, index) => RaffleEditCard(
        title: "Summer Charity Raffle ${index + 1}",
        description: "Enter for a chance to win an all-expenses-paid trip while supporting local youth programs...",
        endDate: "Mar 25, 2026",
        ticketPrice: "\$5.00",
        totalTickets: "500 Sold",
        imageUrl: "https://picsum.photos/seed/raffle$index/400/300",
        onEdit: () => Get.toNamed(
          AppRoutes.editRaffles,
          arguments: {"title": "Edit Raffles"},
        ),
        onView: () {},
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: color, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) => false;
}