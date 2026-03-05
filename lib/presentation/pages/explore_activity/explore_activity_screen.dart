import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/event_card.dart';
import 'package:loci/presentation/widgets/event_edit_card.dart';
import 'package:loci/presentation/widgets/route_card.dart';
import 'package:loci/presentation/widgets/route_edit_card.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/constants/app_text_style.dart';
import '../../../core/utils/activity_type.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/raffles_edit_card.dart';

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
    // TODO: implement initState
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
      appBar: CustomAppbar(title: "Explore Activities"),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //---search bar
            CustomTextField(
              borderColor: context.colorScheme.outline,
              hintText: "Explore Activities",
              hintTextColor: context.colorScheme.onSurfaceVariant,
              textColor: context.colorScheme.onSurface,
              suffixIcon: Icon(
                Icons.search,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            //--- create new activity
            CustomButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Get.toNamed(AppRoutes.createActivity);
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
            const SizedBox(height: 8),
            Text(
              "Track ongoing activities like events, routes or raffles  ",
              style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            //---tabBar
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

            const SizedBox(height: 8),
            //---tabBar view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_eventsTab(), _routesTab(), _rafflesTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- eventTab page
  Widget _eventsTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.all(6.0),
      itemBuilder: (context, index) {
        return EventEditCard(
          imageUrl: "assets/images/finedine.png",
          title: "Spring Pub Crawl Festival",
          description: "...",
          dateTime: "Mon, Jan 19 at 2:50 PM",
          location: "Downtown District",
          attendance: "0 going / 200 max",
          organizerName: "Crawl Events Co.",
          onEditInfo: () {
            Get.toNamed(
              AppRoutes.editEvent,
              arguments: {"title": "Spring Pub Crawl Edit"},
            );
          },
          onViewDetails: () {
            //---view details pass the title of appbar
            Get.toNamed(
              AppRoutes.viewEvent,
              arguments: {"title": "Spring Pub Crawl"},
            );
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 10);
      },
    );
  }

  // ---- routes page
  Widget _routesTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.all(6.0),

      itemBuilder: (context, index) {
        return RouteEditCard(
          title: "Adventure Trail ${index + 1}",
          description:
              "A scenic hike through the valley with breathtaking views...",
          location: "Philadelphia, PA",
          duration: "2h 30m",
          difficulty: "Moderate",
          imageUrl: "https://picsum.photos/seed/${index + 10}/400/300",
          onEdit: () {
            Get.toNamed(
              AppRoutes.editRoutes,
              arguments: {"title": "Routes Edit"},
            );
          },
          onView: () {},
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
    );
  }

  // ---- raffles page

  Widget _rafflesTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(6.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return RaffleEditCard(
          title: "Summer Charity Raffle ${index + 1}",
          description:
              "Enter for a chance to win an all-expenses-paid trip while supporting local youth programs...",
          endDate: "Mar 25, 2026",
          ticketPrice: "\$5.00",
          totalTickets: "500 Sold",
          imageUrl: "https://picsum.photos/seed/raffle${index}/400/300",
          onEdit: () {
            // Handle edit logic
            Get.toNamed(
              AppRoutes.editRaffles,
              arguments: {"title": "Edit Raffles"},
            );
          },
          onView: () {
            // Handle view details logic
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
    );
  }
}
