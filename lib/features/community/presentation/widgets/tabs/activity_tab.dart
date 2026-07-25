import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/event/presentation/controllers/rsvp_controller.dart';
import 'package:loci/features/community/presentation/widgets/activity_card.dart';
import 'package:loci/features/community/presentation/widgets/community_search_bar.dart';
import 'package:loci/features/event/presentation/widgets/event_card.dart';
import 'package:loci/features/routes/presentation/widgets/route_card.dart';
import 'package:loci/features/raffles/presentation/widgets/raffle_card.dart';
import 'package:loci/routes/app_routes.dart';

class ActivityTab extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String postId) onCommentTap;
  final void Function(String postId) onLikeTap;
  final void Function(String eventId, RSVPController rsvpController) onRsvp;

  const ActivityTab({
    super.key,
    required this.searchController,
    required this.onCommentTap,
    required this.onLikeTap,
    required this.onRsvp,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AnnouncementController>();
      final announcements = ctrl.announcements;
      ctrl.announcementMap.length;

      return Column(
        children: [
          CommunitySearchBar(
            controller: searchController,
            hintText: "Search activity",
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final activity = announcements[index];
              final business = activity.business;
              return CommunityActivityCard(
                profileImage: business?.logo ?? "",
                businessName: business?.name ?? "",
                description: activity.details,
                likes: (activity.likeCount ?? 0).toString(),
                comments: (activity.commentCount ?? 0).toString(),
                isLiked: activity.isLiked,
                activityContent: _buildActivityContent(activity),
                onLikeTap: () => onLikeTap(activity.id),
                onCommentTap: () => onCommentTap(activity.id),
                dateTime: formatDateTime(activity.createdAt),
              );
            },
          ),
        ],
      );
    });
  }

  Widget? _buildActivityContent(AnnouncementModel activity) {
    switch (activity.activityRefType) {
      case ActivityRefType.event:
        final event = activity.event;
        if (event == null) return null;
        // RSVPController lives outside assigned dirs and is not yet Rx;
        // announcement Obx rebuilds button text after local RSVP status update.
        final rsvpController = Get.find<RSVPController>();
        return EventCard(
          imageUrl: event.coverImage,
          title: event.title,
          description: event.description,
          date: event.date,
          location: event.location,
          attendance: "${event.goingCount}/${event.maxAttendees}",
          organizer: event.organizerName,
          onTapCard: () => Get.toNamed(
            AppRoutes.eventDetails,
            arguments: {'eventId': event.id, "eventTitle": event.title},
          ),
          onRSVP: () => onRsvp(event.id, rsvpController),
          isLoading:
              rsvpController.isLoading &&
              rsvpController.loadingEventId == event.id,
          rsvpButtonText: event.myRsvpStatus.label,
        );

      case ActivityRefType.route:
        final route = activity.route;
        if (route == null) return null;
        return RouteCard(
          title: route.title,
          description: route.details,
          location: route.location,
          openingTime: route.openingTime,
          availabilityType: route.availabilityType,
          imageUrl: route.banner,
          onTap: () => Get.toNamed(
            AppRoutes.routeDetails,
            arguments: {
              "routeId": route.routeId,
              "routeName": route.title,
              "showAppBar": true,
            },
          ),
        );

      case ActivityRefType.raffle:
        final raffle = activity.raffle;
        if (raffle == null) return null;
        return RaffleCard(
          raffle: raffle,
          onTap: () async => Get.toNamed(
            AppRoutes.rafflesDetails,
            arguments: {"raffleId": raffle.id, "showAppBar": true},
          ),
        );

      default:
        return null;
    }
  }
}
