import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/event/presentation/controllers/rsvp_controller.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/features/event/presentation/controllers/event_list_controller.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';
import '../widgets/event_card.dart';
import '../widgets/event_card_skeleton.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  //----get x controller
  final eventController = Get.find<EventListController>();
  final rsvpController = Get.find<RSVPController>();

  //---scroll controller for pagination loader
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        eventController.loadMoreEvents();
      }
    });

    _searchController.text = eventController.searchQuery;

    eventController.fetchEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    eventController.clearSearch();
    super.dispose();
  }

  //------ event details screen
  void _eventOnTapHandler(String eventId, String eventTitle) {
    FocusScope.of(context).unfocus();
    Get.toNamed(
      AppRoutes.eventDetails,
      arguments: {'eventId': eventId, "eventTitle": eventTitle},
    );
  }

  //------ Rsvp  handle
  void _rsvpOnTapHandler(String eventId) async {
    //call the api to change rsvp status
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _searchController,
              focusNode: _searchFocus,
              borderColor: colors.outline,
              hintText: "Search Event",
              hintTextColor: colors.onSurfaceVariant,
              textColor: colors.onSurface,
              onChanged: eventController.onSearchChanged,
              showClearButton: true,
              onClear: () {
                _searchController.clear();
                eventController.clearSearch();
              },
              suffixIcon: Icon(
                Icons.search,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Upcoming Events",
              style: AppTextStyle.textXl(
                color: colors.onSurface,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "RSVP to the events which you interested",
              style: AppTextStyle.textSm(color: colors.onSurface),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final controller = eventController;
                final hasSearch = controller.searchQuery.trim().isNotEmpty;
                final isInitialLoading = controller.showInitialShimmer;
                final hasFatalError =
                    controller.errorMessage != null &&
                    controller.eventList.isEmpty &&
                    !isInitialLoading;

                return RefreshIndicator(
                  onRefresh: () => controller.fetchEvents(isRefresh: true),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (controller.isRefreshing)
                        const SliverToBoxAdapter(
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                      if (isInitialLoading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: EventCardSkeleton(),
                      ),
                      childCount: 3,
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
                else if (controller.eventList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasSearch
                                ? Icons.search_off_outlined
                                : Icons.event_busy,
                            size: 48,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasSearch
                                ? "No events match \"${controller.searchQuery}\""
                                : "No upcoming events",
                            style: AppTextStyle.textSm(
                              color: context.colorScheme.onSurfaceVariant,
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
                        // Pagination loader
                        if (index == controller.eventList.length) {
                          return const PaginationLoader();
                        }

                        //get single event from data
                        final event = controller.eventList[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Obx(() {
                            final rsvpController = this.rsvpController;
                            // check if button loading
                            bool isThisButtonLoading =
                                rsvpController.isLoading &&
                                event.id == rsvpController.loadingEventId;

                            return EventCard(
                              rsvpButtonText: event.myRsvpStatus.label,
                              onTapCard: () =>
                                  _eventOnTapHandler(event.id, event.title),
                              imageUrl: event.coverImage,
                              title: event.title,
                              description: event.description,
                              date: event.dateLabel,
                              location: event.location,
                              attendance:
                                  "${event.goingCount} going / ${event.maxAttendees} max",
                              organizer: event.organizerName,
                              onRSVP: () => _rsvpOnTapHandler(event.id),
                              isLoading: isThisButtonLoading,
                            );
                          }),
                        );
                      },
                      childCount:
                          controller.eventList.length +
                          (controller.isPaginationLoading ? 1 : 0),
                    ),
                  ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
