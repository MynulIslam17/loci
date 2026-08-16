import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/event/presentation/controllers/event_list_controller.dart';
import 'package:loci/features/event/presentation/controllers/rsvp_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';
import '../widgets/event_card.dart';
import '../widgets/event_card_skeleton.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final eventController = Get.find<EventListController>();
  final rsvpController = Get.find<RSVPController>();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _searchController.text = eventController.searchQuery;
    eventController.fetchEvents();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final showFab = _scrollController.offset > 280;
    if (showFab != _showScrollToTop) {
      setState(() => _showScrollToTop = showFab);
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      eventController.loadMoreEvents();
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
    eventController.clearSearch();
    super.dispose();
  }

  void _eventOnTapHandler(String eventId, String eventTitle) {
    FocusScope.of(context).unfocus();
    Get.toNamed(
      AppRoutes.eventDetails,
      arguments: {'eventId': eventId, "eventTitle": eventTitle},
    );
  }

  void _rsvpOnTapHandler(String eventId) async {
    HapticFeedback.selectionClick();
    bool success = await rsvpController.sendRSVP(
      eventId: eventId,
      status: RsvpStatus.going.toJson,
    );

    if (success) {
      eventController.updateRsvpStatus(eventId, RsvpStatus.going);
      SnackbarService.success(rsvpController.successMessage!);
    } else {
      SnackbarService.error(rsvpController.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 4,
            tooltip: 'Scroll to top',
            child: const Icon(Icons.arrow_upward_rounded, size: 20),
          ),
        ),
      ),
      body: Obx(() {
        final controller = eventController;
        final events = controller.eventList;
        final hasSearch = controller.searchQuery.trim().isNotEmpty;
        final showShimmer =
            controller.showInitialShimmer || controller.isSearching.value;
        final hasFatalError =
            controller.errorMessage != null &&
            controller.eventList.isEmpty &&
            !showShimmer;

        return RefreshIndicator.adaptive(
          color: colors.primary,
          onRefresh: () => controller.fetchEvents(isRefresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── 1. Top Title Section (Scrolls with page) ──────────────────
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
                              'Upcoming Events',
                              style: AppTextStyle.textXl(
                                color: colors.onSurface,
                                weight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'RSVP to the events which you are interested in',
                              style: AppTextStyle.textXs(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (!showShimmer && events.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                size: 14,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${events.length} events',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
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

              // ── 2. Pinned Search Bar (Fixes at top when scrolled) ──────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedSearchBarDelegate(
                  child: Container(
                    height: 68,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: SizedBox(
                      height: 52,
                      child: CustomTextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        hintText: "Search events, topics, or places...",
                        borderColor: colors.outline.withValues(
                          alpha: isDark ? 0.35 : 0.2,
                        ),
                        fontSize: 14,
                        contentPaddingVertical: 12,
                        textColor: colors.onSurface,
                        hintTextColor: colors.onSurfaceVariant,
                        onChanged: eventController.onSearchChanged,
                        showClearButton: true,
                        onClear: () {
                          _searchController.clear();
                          eventController.clearSearch();
                        },
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── 3. Content Body (Skeletons / Error / Empty / List) ─────────
              if (showShimmer)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: EventCardSkeleton(),
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
                    onRetry: () => controller.fetchEvents(),
                  ),
                )
              else if (events.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ModernEmptyState(
                    hasSearch: hasSearch,
                    searchQuery: controller.searchQuery,
                    onResetSearch: () {
                      _searchController.clear();
                      eventController.clearSearch();
                    },
                    onRefresh: () => controller.fetchEvents(isRefresh: true),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == events.length) {
                          return const PaginationLoader();
                        }

                        final event = events[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Obx(() {
                            final rsvpCtrl = rsvpController;
                            final isThisButtonLoading =
                                rsvpCtrl.isLoading &&
                                event.id == rsvpCtrl.loadingEventId;

                            return EventCard(
                              rsvpButtonText: event.myRsvpStatus.label,
                              onTapCard: () => _eventOnTapHandler(
                                event.id,
                                event.title,
                              ),
                              imageUrl: event.coverImage,
                              title: event.title,
                              description: event.description,
                              date: event.dateLabel,
                              rawDate: event.date,
                              location: event.location,
                              attendance:
                                  "${event.goingCount} going / ${event.maxAttendees} max",
                              goingCount: event.goingCount,
                              maxAttendees: event.maxAttendees,
                              organizer: event.organizerName,
                              organizerAvatar: event.organizerAvatar,
                              isPublic: event.isPublic,
                              myRsvpStatus: event.myRsvpStatus,
                              onRSVP: () => _rsvpOnTapHandler(event.id),
                              isLoading: isThisButtonLoading,
                            );
                          }),
                        );
                      },
                      childCount:
                          events.length +
                          (controller.isPaginationLoading ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

/// Sliver persistent header delegate for pinning the search bar with smooth frosted glass & bottom fade
class _PinnedSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PinnedSearchBarDelegate({required this.child});

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
              // Smooth bottom gradient transition line
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
  bool shouldRebuild(covariant _PinnedSearchBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

/// Modern illustrated empty state
class _ModernEmptyState extends StatelessWidget {
  final bool hasSearch;
  final String searchQuery;
  final VoidCallback onResetSearch;
  final VoidCallback onRefresh;

  const _ModernEmptyState({
    required this.hasSearch,
    required this.searchQuery,
    required this.onResetSearch,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    final title = hasSearch ? "No events found" : "No Upcoming Events";
    final subtitle = hasSearch
        ? 'We couldn\'t find any events matching "$searchQuery"'
        : "Stay tuned! New community events will appear here soon";
    final buttonText = hasSearch ? "Clear Search" : "Refresh";
    final onButtonTap = hasSearch ? onResetSearch : onRefresh;
    final icon =
        hasSearch ? Icons.search_off_rounded : Icons.calendar_today_rounded;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 40, color: colors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyle.textLg(
                color: colors.onSurface,
                weight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyle.textSm(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onButtonTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
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
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




