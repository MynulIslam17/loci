import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/routes/presentation/controllers/route_list_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.text = routeController.searchQuery;
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
    FocusScope.of(context).unfocus();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
      body: RefreshIndicator.adaptive(
        color: colorScheme.primary,
        onRefresh: () => routeController.fetchRoutes(isRefresh: true),
        child: Obx(() {
          final controller = routeController;
          final routes = controller.routeList;
          final hasSearch = controller.searchQuery.trim().isNotEmpty;
          final showShimmer = controller.showInitialShimmer;
          final hasFatalError =
              controller.errorMessage != null &&
              routes.isEmpty &&
              !showShimmer;

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── 1. Top Title Section (Scrolls with content) ───────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Routes',
                              style: AppTextStyle.textXl(
                                color: colorScheme.onSurface,
                                weight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Discover pub crawls, shop hopping, and scavenger hunts',
                              style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (!showShimmer && routes.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.explore_outlined,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${routes.length} routes',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── 2. Pinned Search Bar (Fixes at top on scroll) ─────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedRouteSearchBarDelegate(
                  child: Container(
                    height: 68,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: SizedBox(
                      height: 52,
                      child: CustomTextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        hintText: "Search routes by name or place...",
                        borderColor: colorScheme.outline.withValues(
                          alpha: isDark ? 0.35 : 0.2,
                        ),
                        fontSize: 14,
                        contentPaddingVertical: 12,
                        textColor: colorScheme.onSurface,
                        hintTextColor: colorScheme.onSurfaceVariant,
                        onChanged: routeController.onSearchChanged,
                        showClearButton: true,
                        onClear: () {
                          _searchController.clear();
                          routeController.clearSearch();
                        },
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── 3. Content Body ───────────────────────────────────────────
              if (showShimmer)
                SliverPadding(
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
                )
              else if (hasFatalError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateWidget(
                    message: controller.errorMessage!,
                    onRetry: () => controller.fetchRoutes(),
                  ),
                )
              else if (routes.isEmpty)
                SliverFillRemaining(
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
                )
              else
                SliverPadding(
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
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// Pinned search bar delegate for routes
class _PinnedRouteSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PinnedRouteSearchBarDelegate({required this.child});

  @override
  double get minExtent => 68.0;

  @override
  double get maxExtent => 68.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isScrolled = shrinkOffset > 0 || overlapsContent;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(
                  alpha: isScrolled ? (isDark ? 0.88 : 0.92) : 1.0,
                ),
            boxShadow: isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.22 : 0.05,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              child,
              if (isScrolled)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.outline.withValues(
                            alpha: isDark ? 0.15 : 0.08,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedRouteSearchBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

