import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/event_edit_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_empty_sliver.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_footer.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_tab_scroll.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/error_state.dart';

class ExploreActivityEventsTab extends StatefulWidget {
  const ExploreActivityEventsTab({super.key, required this.businessId});

  final String businessId;

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
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
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

    if (!_controller.isLoading.value && _controller.eventList.isEmpty) {
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
            final result = await Get.toNamed(
              AppRoutes.editEvent,
              arguments: {'eventId': event.id},
            );
            if (result == true) {
              _controller.fetchEvents(
                forceRefresh: true,
                businessId: widget.businessId,
              );
            }
          },
          onViewDetails: () => Get.toNamed(
            AppRoutes.viewEvent,
            arguments: {'eventId': event.id, 'title': event.title},
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }
}
