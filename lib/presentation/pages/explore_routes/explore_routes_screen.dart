import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/explore_routes/route_details_screen.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import '../../controllers/routes/route_list_controller.dart';
import 'widgets/route_card.dart';

class ExploreRoutesScreen extends StatelessWidget {
  const ExploreRoutesScreen({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_)=>const ExploreRoutesPage()
      ),
    );
  }
}

class ExploreRoutesPage extends StatefulWidget {
  const ExploreRoutesPage({super.key});

  @override
  State<ExploreRoutesPage> createState() => _ExploreRoutesPageState();
}

class _ExploreRoutesPageState extends State<ExploreRoutesPage> {
  final routeController = Get.find<RouteListController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        routeController.loadMoreRoutes();
      }
    });

    //routes call
    routeController.fetchRoutes();

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  //----- onTapRouteHandler----------------------------
  void _onTapRouteHandler(BuildContext context,String routeId,String routeName) {

    Navigator.push(
        context, MaterialPageRoute(
        builder: (_)=>RouteDetailsScreen(showAppbar: false,routeId:routeId ,routeName: routeName,)
    )
    );


  }




  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GetBuilder<RouteListController>(
        builder: (controller) {
          // Loading
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (controller.errorMessage != null && controller.routeList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage!,
                    style: AppTextStyle.textSm(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => controller.fetchRoutes(),
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            );
          }

          // Empty
          if (controller.routeList.isEmpty) {
            return Center(
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
                ],
              ),
            );
          }

          // List + Refresh + Pagination
          return RefreshIndicator(
            onRefresh: () => controller.fetchRoutes(isRefresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Search + Header
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: "Search Routes",
                        hintTextColor: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        borderColor: colorScheme.outline,
                        textColor: colorScheme.onSurface,
                        suffixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Explore Routes",
                        style: AppTextStyle.textXl(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Discover pub crawls, shop hopping, and scavenger hunts",
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Route List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Pagination loader
                      if (index == controller.routeList.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final route = controller.routeList[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: RouteCard(
                          title: route.title,
                          description: route.details,
                          location: route.location,
                          openingTime: route.openingTime,
                          availabilityType: route.availabilityType,
                          imageUrl: route.banner,
                          onTap:(){

                            _onTapRouteHandler(context,route.routeId,route.title);
                          }
                        ),
                      );
                    },
                    childCount:
                        controller.routeList.length +
                        (controller.isPaginationLoading ? 1 : 0),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}
