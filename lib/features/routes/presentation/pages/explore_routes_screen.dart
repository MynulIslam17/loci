import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/routes/presentation/controllers/route_list_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/error_state.dart';
import '../widgets/route_card.dart';
import '../widgets/route_card_skeleton.dart';

/// List of routes shown inside the main shell drawer overlay.
class ExploreRoutesPage extends StatefulWidget {
  const ExploreRoutesPage({super.key});

  @override
  State<ExploreRoutesPage> createState() => _ExploreRoutesPageState();
}

class _ExploreRoutesPageState extends State<ExploreRoutesPage> {
  final routeController = Get.find<RouteListController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        routeController.loadMoreRoutes();
      }
    });

    _searchController.text = routeController.searchQuery;

    //routes call
    routeController.fetchRoutes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTapRouteHandler(String routeId, String routeName) {
    Get.toNamed(
      AppRoutes.routeDetails,
      arguments: {
        'routeId': routeId,
        'routeName': routeName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() {
        final controller = routeController;
        final hasSearch = controller.searchQuery.trim().isNotEmpty;
        final isInitialLoading = controller.showInitialShimmer;
        final hasFatalError =
            controller.errorMessage != null &&
            controller.routeList.isEmpty &&
            !isInitialLoading;

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
                      controller: _searchController,
                      hintText: "Search Routes",
                      hintTextColor: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      borderColor: colorScheme.outline,
                      textColor: colorScheme.onSurface,
                      onChanged: controller.onSearchChanged,
                      showClearButton: true,
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

              if (isInitialLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: RouteCardSkeleton(),
                    ),
                    childCount: 3,
                  ),
                )
              else if (hasFatalError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateWidget(
                    message: controller.errorMessage!,
                    onRetry: () => controller.fetchRoutes(),
                  ),
                )
              else if (controller.routeList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasSearch ? Icons.search_off_outlined : Icons.route,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hasSearch
                              ? "No routes match \"${controller.searchQuery}\""
                              : "No routes found",
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Pagination skeleton
                      if (index == controller.routeList.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: RouteCardSkeleton(),
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
                          onTap: () {
                            _onTapRouteHandler(
                              route.routeId,
                              route.title,
                            );
                          },
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
      }),
    );
  }
}
