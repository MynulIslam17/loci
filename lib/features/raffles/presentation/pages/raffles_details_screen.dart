import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_hero.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_info_row.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_organizer_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffle_prize_chip.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffle_progress.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_section.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_status_badge.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_visibility_badge.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';
import 'package:loci/features/raffles/presentation/controllers/raffle_details_controller.dart';
import 'package:loci/features/raffles/presentation/widgets/raffles_details_shimmer.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/task_card.dart';

class RafflesDetailsScreen extends StatefulWidget {
  final String? raffleId;
  final bool showAppBar;

  const RafflesDetailsScreen({
    super.key,
    this.raffleId,
    this.showAppBar = true,
  });

  @override
  State<RafflesDetailsScreen> createState() => _RafflesDetailsScreenState();
}

class _RafflesDetailsScreenState extends State<RafflesDetailsScreen> {
  late final RaffleDetailsController _controller;
  late final String _activeRaffleId;
  late final bool _showAppBar;

  @override
  void initState() {
    super.initState();

    _controller = Get.isRegistered<RaffleDetailsController>()
        ? Get.find<RaffleDetailsController>()
        : Get.put(RaffleDetailsController(Get.find<RafflesService>()));

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _activeRaffleId = args['raffleId']?.toString() ?? '';
      _showAppBar = args['showAppBar'] ?? true;
    } else {
      _activeRaffleId = widget.raffleId ?? '';
      _showAppBar = widget.showAppBar;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_activeRaffleId.isNotEmpty) {
        _controller.fetchRaffleDetails(_activeRaffleId);
      }
    });
  }

  Future<void> _taskHandler(RaffleTaskModel task) async {
    if (task.isCompleted) return;

    final activity = task.activity;
    if (activity == null || activity.id.isEmpty) return;

    final result = await Get.toNamed(
      task.isRouteTask ? AppRoutes.routeDetails : AppRoutes.eventDetails,
      arguments: task.isRouteTask
          ? {
              'routeName': activity.title,
              'routeId': activity.id,
            }
          : {
              'eventTitle': activity.title,
              'eventId': activity.id,
            },
    );

    // No re-fetch — pull-to-refresh covers that. Update the matching task locally.
    if (result is Map && result['checkedIn'] == true) {
      final checkedInId = result['entityId']?.toString() ?? activity.id;
      _controller.markTaskCompletedByActivityId(checkedInId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _showAppBar ? const CustomAppbar(title: 'Raffle Details') : null,
      body: Obx(() {
        if (_controller.isLoading) {
          return const RafflesDetailsShimmer();
        }

        if (_controller.errorMessage != null &&
            _controller.raffleDetails == null) {
          return ErrorStateWidget(
            message: _controller.errorMessage!,
            onRetry: () => _controller.fetchRaffleDetails(_activeRaffleId),
          );
        }

        final details = _controller.raffleDetails;
        if (details == null) {
          return const Center(child: Text('No raffle found'));
        }

        return AdaptiveRefresh(
          onRefresh: () => _controller.refreshRaffleDetails(_activeRaffleId),
          child: _RaffleDetailsBody(
            details: details,
            onTaskTap: _taskHandler,
          ),
        );
      }),
    );
  }
}

class _RaffleDetailsBody extends StatelessWidget {
  const _RaffleDetailsBody({
    required this.details,
    required this.onTaskTap,
  });

  final RaffleDetailsModel details;
  final void Function(RaffleTaskModel task) onTaskTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final raffle = details.raffleModel;
    final tasks = details.tasks;
    final sponsor = details.sponsor;

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
            badges: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (details.status.isNotEmpty)
                  ExploreActivityStatusBadge(status: details.status),
                ExploreActivityVisibilityBadge(isPublic: details.isPublic),
              ],
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
          title: 'Your progress',
          highlightTitle: true,
          child: ExploreActivityRaffleProgress(tasks: tasks),
        ),
        ExploreActivitySection(
          title: 'Entry requirements',
          subtitle: 'Complete each task to enter the raffle',
          highlightTitle: true,
          child: tasks.isEmpty
              ? Text(
                  'No entry requirements for this raffle.',
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurfaceVariant,
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
                      id: activity?.id ?? 'task_${task.order}',
                      step: task.order,
                      typeLabel: task.isRouteTask ? 'Route' : 'Event',
                      title: activity?.title ?? 'Unknown activity',
                      description: task.isCompleted
                          ? 'Completed'
                          : 'Tap to check-in',
                      imageUrl: activity?.banner,
                      isCompleted: task.isCompleted,
                      onTap: task.isCompleted ? null : () => onTaskTap(task),
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
