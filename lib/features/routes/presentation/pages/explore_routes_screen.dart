import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/routes/presentation/controllers/route_list_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/adaptive_expandable_search_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';
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
  final FocusNode _searchFocus = FocusNode();

  bool _showScrollToTop = false;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.text = '';
    _isSearchExpanded = false;
    routeController.fetchRoutes();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final showFab = _scrollController.offset > 280;
    if (showFab != _showScrollToTop) {
      setState(() => _showScrollToTop = showFab);
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      routeController.loadMoreRoutes();
    }
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _resetSearchToDefault() {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchFocus.unfocus();
    if (_isSearchExpanded || _searchController.text.isNotEmpty) {
      setState(() => _isSearchExpanded = false);
      _searchController.clear();
      routeController.clearSearch();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    routeController.clearSearch();
    super.dispose();
  }

  void _onTapRouteHandler(String routeId, String routeName) {
    _resetSearchToDefault();
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _showScrollToTop ? Offset.zero : const Offset(0, 2),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _showScrollToTop ? 1.0 : 0.0,
          curve: Curves.easeInOut,
          child: FloatingActionButton.small(
            onPressed: _showScrollToTop ? _scrollToTop : null,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
            tooltip: 'Scroll to top',
            child: const Icon(Icons.arrow_upward_rounded, size: 20),
          ),
        ),
      ),
      body: AdaptiveRefresh(
        color: colorScheme.primary,
        onRefresh: () => routeController.fetchRoutes(isRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── 1. Floating Quick-Return Search Header (iOS Glass / Android M3) ─
            SliverPersistentHeader(
              pinned: _isSearchExpanded ||
                  routeController.searchQuery.isNotEmpty,
              floating: !_isSearchExpanded &&
                  routeController.searchQuery.isEmpty,
              delegate: AdaptivePinnedSearchDelegate(
                child: AdaptiveExpandableSearchHeader(
                  title: 'Explore Routes',
                  subtitle: 'Discover pub crawls, shop hopping, and scavenger hunts',
                  hintText: 'Search routes by name or place...',
                  searchController: _searchController,
                  searchFocus: _searchFocus,
                  isExpanded: _isSearchExpanded ||
                      routeController.searchQuery.isNotEmpty,
                  onToggleExpand: (expanded) {
                    setState(() => _isSearchExpanded = expanded);
                  },
                  onSearchChanged: routeController.onSearchChanged,
                  onSearchSubmitted: (v) => routeController.submitSearch(v),
                  onClear: () {
                    routeController.clearSearch();
                  },
                ),
              ),
            ),

            // ── 2. Content Body ───────────────────────────────────────────
            // Only content is reactive via Obx
            Obx(() {
              final controller = routeController;
              final routes = controller.routeList;
              final hasSearch = controller.searchQuery.trim().isNotEmpty;
              final showShimmer =
                  controller.showInitialShimmer || controller.isSearching.value;
              final hasFatalError =
                  controller.errorMessage != null &&
                  routes.isEmpty &&
                  !showShimmer;

              if (showShimmer) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: RouteCardSkeleton(),
                      ),
                      childCount: 3,
                    ),
                  ),
                );
              }

              if (hasFatalError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateWidget(
                    message: controller.errorMessage!,
                    onRetry: () => controller.fetchRoutes(),
                  ),
                );
              }

              if (routes.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              hasSearch
                                  ? Icons.search_off_rounded
                                  : Icons.route_rounded,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            hasSearch ? "No routes found" : "No Routes Available",
                            style: AppTextStyle.textLg(
                              color: colorScheme.onSurface,
                              weight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hasSearch
                                ? "No routes match \"${controller.searchQuery}\""
                                : "Check back soon for new community routes and trails",
                            style: AppTextStyle.textSm(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (hasSearch) {
                                _searchController.clear();
                                routeController.clearSearch();
                              } else {
                                routeController.fetchRoutes(isRefresh: true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              hasSearch ? "Clear Search" : "Refresh",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == routes.length) {
                        return const PaginationLoader();
                      }

                      final route = routes[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
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
                        routes.length +
                        (controller.isPaginationLoading ? 1 : 0),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
