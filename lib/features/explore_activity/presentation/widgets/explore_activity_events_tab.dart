import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/utils/explore_activity_search_focus.dart';
import 'package:loci/features/explore_activity/presentation/widgets/event_edit_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_empty_sliver.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_footer.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_shimmer.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_tab_scroll.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/error_state.dart';

class ExploreActivityEventsTab extends StatefulWidget {
  const ExploreActivityEventsTab({
    super.key,
    required this.businessId,
    required this.searchFocus,
  });

  final String businessId;
  final ExploreActivitySearchFocus searchFocus;

  @override
  State<ExploreActivityEventsTab> createState() =>
      _ExploreActivityEventsTabState();
}

class _ExploreActivityEventsTabState extends State<ExploreActivityEventsTab>
    with AutomaticKeepAliveClientMixin {
  final _controller = Get.find<BusinessEventListController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      return ExploreActivityTabScroll(
        isLoading: _controller.showInitialLoader(widget.businessId),
        isRefreshing: _controller.isRefreshing.value,
        isPaginationLoading: _controller.isPaginationLoading.value,
        onRefresh: () => _controller.fetchEvents(
          businessId: widget.businessId,
          forceRefresh: true,
        ),
        onLoadMore: () =>
            _controller.loadMoreEvents(businessId: widget.businessId),
        sliver: _buildSliver(),
      );
    });
  }

  Widget _buildSliver() {
    if (_controller.showInitialLoader(widget.businessId)) {
      return ExploreActivityListShimmer.sliver();
    }

    if (_controller.errorMessage.value != null &&
        _controller.eventList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateWidget(
          message: _controller.errorMessage.value!,
          onRetry: () => _controller.fetchEvents(
            businessId: widget.businessId,
            forceRefresh: true,
          ),
        ),
      );
    }

    if (_controller.showEmptyState(widget.businessId)) {
      return const ExploreActivityEmptySliver(
        icon: Icons.event_outlined,
        title: 'No events yet',
        subtitle: 'Create an event to see it here',
      );
    }

    return SliverList.separated(
      itemCount: _controller.eventList.length + 1,
      itemBuilder: (context, index) {
        if (index == _controller.eventList.length) {
          return ExploreActivityListFooter(
            isLoading: _controller.isPaginationLoading.value,
            hasMore: _controller.hasMore.value,
            endLabel: 'No more events',
          );
        }

        final event = _controller.eventList[index];
        return EventEditCard(
          imageUrl: event.coverImage,
          title: event.title,
          description: event.description,
          dateTime: event.date,
          location: event.location,
          attendance: '${event.goingCount} going / ${event.maxAttendees} max',
          organizerName: event.organizerName,
          onEditInfo: () async {
            final result = await widget.searchFocus.guard(
              () => Get.toNamed(
                AppRoutes.editEvent,
                arguments: {
                  'eventId': event.id,
                  'businessId': widget.businessId,
                },
              ),
            );
            if (result == true) {
              _controller.fetchEvents(
                forceRefresh: true,
                businessId: widget.businessId,
              );
            }
          },
          onViewDetails: () {
            widget.searchFocus.guard(
              () => Get.toNamed(
                AppRoutes.viewEvent,
                arguments: {
                  'eventId': event.id,
                  'title': event.title,
                  'businessId': widget.businessId,
                },
              ),
            );
          },
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 10),
    );
  }
}
