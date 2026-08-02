import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/routeType.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffle_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_hero.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_info_row.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_map_preview.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_organizer_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_qr_button.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffle_prize_chip.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_stat_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_status_badge.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_visibility_badge.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/qrcode_maker.dart';
import 'package:loci/shared/widgets/task_card.dart';

/// Type-specific sections for [ViewActivityScreen].
class ViewActivityDetailContent extends StatelessWidget {
  const ViewActivityDetailContent({
    super.key,
    required this.activityType,
  });

  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    return switch (activityType) {
      ActivityType.event => const _EventDetailContent(),
      ActivityType.routes => const _RouteDetailContent(),
      ActivityType.raffles => const _RaffleDetailContent(),
    };
  }
}

class _EventDetailContent extends StatelessWidget {
  const _EventDetailContent();

  @override
  Widget build(BuildContext context) {
    final eventDetails = Get.find<BusinessEventDetailsController>()
        .eventDetails
        .value!;
    final event = eventDetails.eventModel;
    final organization = eventDetails.organizerBusiness;
    final eventDateLabel = _formatEventDate(event.date);

    return ExploreActivityDetailScroll(
      children: [
        ExploreActivitySection(
          child: ExploreActivityDetailHero(
            imageUrl: event.coverImage,
            title: event.title,
            description: event.description,
            badges: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (eventDetails.status.isNotEmpty)
                  ExploreActivityStatusBadge(status: eventDetails.status),
                ExploreActivityVisibilityBadge(isPublic: event.isPublic),
              ],
            ),
          ),
        ),
        ExploreActivitySection(
          title: 'Details',
          highlightTitle: true,
          child: Column(
            children: [
              ExploreActivityInfoRow(
                icon: Icons.calendar_today_outlined,
                text: eventDateLabel,
              ),
              const SizedBox(height: 10),
              ExploreActivityInfoRow(
                icon: Icons.access_time,
                text: event.eventTime,
              ),
              const SizedBox(height: 10),
              ExploreActivityInfoRow(
                icon: Icons.location_on_outlined,
                text: event.location,
              ),
              const SizedBox(height: 10),
              ExploreActivityInfoRow(
                icon: Icons.groups_outlined,
                text:
                    '${event.goingCount}/${event.maxAttendees} participants',
              ),
            ],
          ),
        ),
        ExploreActivitySection(
          title: 'Engagement',
          highlightTitle: true,
          child: Row(
            children: [
              Expanded(
                child: ExploreActivityStatCard(
                  icon: Icons.groups_outlined,
                  count: '${eventDetails.rsvpCount}',
                  label: 'Total RSVP',
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.viewTotalRSVP,
                      arguments: {'title': 'Total RSVP'},
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ExploreActivityStatCard(
                  icon: Icons.person_search_outlined,
                  count: '${eventDetails.checkInCount}',
                  label: 'Check-ins',
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.viewTotalCheckIn,
                      arguments: {'title': 'Total Check-In'},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ExploreActivitySection(
          title: 'Check-in',
          highlightTitle: true,
          child: ExploreActivityQrButton(
            label: 'View QR code',
            onPressed: () {
              CustomQrCode.show(
                context,
                data: eventDetails.qrCode,
                title: event.title,
                subtitle: 'Scan this QR to check-in to this event',
                appName: 'Loci',
              );
            },
          ),
        ),
        const ExploreActivitySection(
          title: 'Location',
          highlightTitle: true,
          child: ExploreActivityMapPreview(height: 150),
        ),
        ExploreActivityOrganizerSection(
          name: organization.name,
          description: organization.description.isNotEmpty
              ? organization.description
              : organization.address,
          logo: organization.logo ?? '',
          highlightTitle: true,
        ),
      ],
    );
  }
}

String _formatEventDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    return DateParserHelper.toFriendlyDate(parsed.toLocal());
  }
  return raw.isNotEmpty ? raw : 'N/A';
}

Widget _activityStatusBadges({
  required String status,
  required bool isPublic,
}) {
  return Wrap(
    spacing: 8,
    runSpacing: 6,
    children: [
      if (status.isNotEmpty) ExploreActivityStatusBadge(status: status),
      ExploreActivityVisibilityBadge(isPublic: isPublic),
    ],
  );
}

class _RouteDetailContent extends StatelessWidget {
  const _RouteDetailContent();

  @override
  Widget build(BuildContext context) {
    final routeDetails =
        Get.find<BusinessRouteDetailsController>().routeDetails.value!;
    final route = routeDetails.routeModel;
    final organizer = routeDetails.organizerBusiness;
    final availabilityLabel =
        RouteType.fromString(route.availabilityType).label;

    return ExploreActivityDetailScroll(
      children: [
        ExploreActivitySection(
          child: ExploreActivityDetailHero(
            imageUrl: route.banner,
            title: route.title,
            description: route.details,
            badges: _activityStatusBadges(
              status: routeDetails.status,
              isPublic: route.isRoutePublic,
            ),
          ),
        ),
        ExploreActivitySection(
          title: 'Route details',
          highlightTitle: true,
          child: Column(
            children: [
              ExploreActivityInfoRow(
                icon: Icons.location_on_outlined,
                text: route.location,
              ),
              const SizedBox(height: 10),
              ExploreActivityInfoRow(
                icon: Icons.access_time,
                text: route.openingTime.isNotEmpty ? route.openingTime : 'N/A',
              ),
              const SizedBox(height: 10),
              ExploreActivityInfoRow(
                icon: Icons.route_outlined,
                text: availabilityLabel,
              ),
            ],
          ),
        ),
        ExploreActivitySection(
          title: 'Engagement',
          highlightTitle: true,
          child: ExploreActivityStatCard(
            icon: Icons.person_outline,
            count: '${routeDetails.checkInCount}',
            label: 'Check-ins',
            onTap: () {},
          ),
        ),
        ExploreActivitySection(
          title: 'Check-in',
          highlightTitle: true,
          child: ExploreActivityQrButton(
            label: 'Download QR code',
            icon: Icons.qr_code_scanner,
            onPressed: () {
              CustomQrCode.show(
                context,
                data: routeDetails.qrCode,
                title: route.title,
                subtitle: 'Scan this QR to check-in to this route',
                appName: 'Loci',
              );
            },
          ),
        ),
        const ExploreActivitySection(
          title: 'Location',
          highlightTitle: true,
          child: ExploreActivityMapPreview(),
        ),
        ExploreActivityOrganizerSection(
          name: organizer.name,
          description: organizer.description ?? '',
          logo: organizer.logo ?? '',
          highlightTitle: true,
        ),
      ],
    );
  }
}

class _RaffleDetailContent extends StatelessWidget {
  const _RaffleDetailContent();

  void _openLinkedActivity(RaffleTaskModel task) {
    final activity = task.activity;
    if (activity == null || activity.id.isEmpty) return;

    final raffleController = Get.find<BusinessRaffleDetailsController>();

    if (task.isRouteTask) {
      Get.toNamed(
        AppRoutes.viewRoutes,
        arguments: {
          'routeId': activity.id,
          'routeName': activity.title,
          'businessId': raffleController.businessId,
          'activityType': ActivityType.routes.name,
        },
      );
      return;
    }

    Get.toNamed(
      AppRoutes.viewEvent,
      arguments: {
        'eventId': activity.id,
        'title': activity.title,
        'businessId': raffleController.businessId,
        'activityType': ActivityType.event.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rafflesDetails =
        Get.find<BusinessRaffleDetailsController>().raffleDetails.value!;
    final raffle = rafflesDetails.raffleModel;
    final tasks = rafflesDetails.tasks;
    final sponsor = rafflesDetails.sponsor;
    final colorScheme = context.colorScheme;

    final dateRange =
        '${DateParserHelper.shortDate(DateTime.parse(raffle.startDate))} - '
        '${DateParserHelper.shortDate(DateTime.parse(raffle.endDate))}';

    return ExploreActivityDetailScroll(
      children: [
        ExploreActivitySection(
          child: ExploreActivityDetailHero(
            imageUrl: raffle.banner,
            title: raffle.title,
            description: raffle.description,
            badges: _activityStatusBadges(
              status: rafflesDetails.status,
              isPublic: rafflesDetails.isPublic,
            ),
            belowTitle: ExploreActivityInfoRow(
              icon: Icons.calendar_today_outlined,
              text: dateRange,
              textColor: colorScheme.primary,
            ),
          ),
        ),
        ExploreActivitySection(
          title: 'Prize',
          highlightTitle: true,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ExploreActivityRafflePrizeChip(label: raffle.bundleName),
              ),
            ],
          ),
        ),
        ExploreActivitySection(
          title: 'Engagement',
          highlightTitle: true,
          child: Row(
            children: [
              Expanded(
                child: ExploreActivityStatCard(
                  icon: Icons.people_outline_rounded,
                  count: '${rafflesDetails.participantCount}',
                  label: 'Participants',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ExploreActivityStatCard(
                  icon: Icons.checklist_rounded,
                  count: '${rafflesDetails.totalTasks}',
                  label: 'Requirements',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        ExploreActivitySection(
          title: 'Entry requirements',
          subtitle: 'Tap a task to preview the linked activity',
          highlightTitle: true,
          child: tasks.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.playlist_add_rounded,
                        size: 32,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No entry requirements yet',
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Edit this raffle to add tasks participants must complete',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final activity = task.activity;

                    return TaskCard(
                      id: activity?.id ?? 'task_$index',
                      step: task.order,
                      title: activity?.title ?? 'Untitled activity',
                      description: activity?.details ?? 'No description',
                      imageUrl: activity?.banner ?? '',
                      typeLabel: task.isRouteTask ? 'Route' : 'Event',
                      onTap: () => _openLinkedActivity(task),
                    );
                  },
                ),
        ),
        ExploreActivityOrganizerSection(
          title: 'Sponsor',
          name: sponsor.name,
          description: sponsor.description,
          logo: sponsor.logo,
          highlightTitle: true,
        ),
      ],
    );
  }
}
