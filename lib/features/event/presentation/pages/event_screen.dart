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
import 'package:loci/shared/widgets/adaptive_expandable_search_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
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
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _searchController.text = '';
    _isSearchExpanded = false;
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

  void _resetSearchToDefault() {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchFocus.unfocus();
    if (_isSearchExpanded || _searchController.text.isNotEmpty) {
      setState(() => _isSearchExpanded = false);
      _searchController.clear();
      eventController.clearSearch();
    }
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
    _resetSearchToDefault();
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

    return Scaffold(
      backgroundColor: colors.surface,
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
      body: AdaptiveRefresh(
        color: colors.primary,
        onRefresh: () => eventController.fetchEvents(isRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── 1. Floating Quick-Return Search Header (iOS Glass / Android M3) ─
            SliverPersistentHeader(
              pinned: _isSearchExpanded || eventController.searchQuery.isNotEmpty,
              floating:
                  !_isSearchExpanded && eventController.searchQuery.isEmpty,
              delegate: AdaptivePinnedSearchDelegate(
                child: AdaptiveExpandableSearchHeader(
                  title: 'Upcoming Events',
                  subtitle: 'RSVP to events you are interested in',
                  searchController: _searchController,
                  searchFocus: _searchFocus,
                  isExpanded: _isSearchExpanded ||
                      eventController.searchQuery.isNotEmpty,
                  onToggleExpand: (expanded) {
                    setState(() => _isSearchExpanded = expanded);
                  },
                  onSearchChanged: eventController.onSearchChanged,
                  onSearchSubmitted: (v) =>
                      eventController.submitSearch(v),
                  onClear: () {
                    eventController.clearSearch();
                  },
                ),
              ),
            ),

            // ── 2. Content Body (Skeletons / Error / Empty / List) ─────────
            // Only content is reactive via Obx
            Obx(() {
              final controller = eventController;
              final events = controller.eventList;
              final hasSearch = controller.searchQuery.trim().isNotEmpty;
              final showShimmer =
                  controller.showInitialShimmer || controller.isSearching.value;
              final hasFatalError =
                  controller.errorMessage != null &&
                  controller.eventList.isEmpty &&
                  !showShimmer;

              if (showShimmer) {
                return SliverPadding(
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
                );
              }

              if (hasFatalError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateWidget(
                    message: controller.errorMessage!,
                    onRetry: () => controller.fetchEvents(),
                  ),
                );
              }

              if (events.isEmpty) {
                return SliverFillRemaining(
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
                );
              }

              return SliverPadding(
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
              );
            }),
          ],
        ),
      ),
    );
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




