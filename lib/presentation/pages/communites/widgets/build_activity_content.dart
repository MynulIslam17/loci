import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/presentation/pages/event/widgets/event_card.dart';
import 'package:loci/presentation/pages/explore_routes/widgets/route_card.dart';
import 'package:loci/presentation/pages/raffles/widgets/raffle_card.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../../data/models/community/announcement_model.dart';

/// ------------------------------
/// ACTIVITY CONTENT BUILDER
/// ------------------------------
Widget? buildActivityContent(AnnouncementModel activity) {
  switch (activity.activityRefType) {

  // EVENT
    case ActivityRefType.event:
      final event = activity.event;
      if (event == null) return null;

      return EventCard(
        imageUrl: event.coverImage,
        title: event.title,
        description: event.description,
        date: event.date,
        location: event.location,
        attendance: "${event.goingCount}/${event.maxAttendees}",
        organizer: event.organizerName,

        onTapCard: () {
          Get.toNamed(AppRoutes.eventDetails, arguments: {
            'eventId': event.id,
            "eventTitle": event.title,
          });
        },

        onRSVP: () {},

        isLoading: false,
        rsvpButtonText: event.myRsvpStatus.label,
      );

  // ROUTE
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

        onTap: () {
          Get.toNamed(AppRoutes.routeDetails, arguments: {
            "routeId": route.routeId,
            "routeName": route.title,
            "showAppBar": true,
          });
        },
      );

  // RAFFLE
    case ActivityRefType.raffle:
      final raffle = activity.raffle;
      if (raffle == null) return null;

      return RaffleCard(
        raffle: raffle,
        onTap: () {
          Get.toNamed(AppRoutes.rafflesDetails, arguments: {
            "raffleId": raffle.id,
            "showAppBar": true,
          });
        },
      );

    default:
      return null;
  }
}