import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/gallery_image_downloader.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_status_badge.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_visibility_badge.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';
import 'package:loci/features/raffles/presentation/controllers/raffle_details_controller.dart';
import 'package:loci/features/raffles/presentation/widgets/raffles_details_shimmer.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/persistent_action_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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

    if (result is Map && result['checkedIn'] == true) {
      final checkedInId = result['entityId']?.toString() ?? activity.id;
      _controller.markTaskCompletedByActivityId(checkedInId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Obx(() {
      final details = _controller.raffleDetails;
      final bool showBottomCta = !_controller.isLoading &&
          _controller.errorMessage == null &&
          details != null;

      final tasks = details?.tasks ?? [];
      final completedTasks = tasks.where((t) => t.isCompleted).length;
      final isAllCompleted = tasks.isNotEmpty && completedTasks == tasks.length;

      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar:
            _showAppBar ? const CustomAppbar(title: 'Raffle Details') : null,
        body: () {
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

          if (details == null) {
            return const Center(child: Text('No raffle found'));
          }

          return AdaptiveRefresh(
            onRefresh: () => _controller.refreshRaffleDetails(_activeRaffleId),
            child: _RaffleDetailsContent(
              details: details,
              controller: _controller,
              raffleId: _activeRaffleId,
              onTaskTap: _taskHandler,
            ),
          );
        }(),
        bottomNavigationBar: showBottomCta
            ? PersistentActionBar(
                child: !details.isParticipating
                    ? SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: CustomButton(
                          text: 'Enter Raffle',
                          isLoading: _controller.isJoining,
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                          textStyle:
                              AppTextStyle.textSm(weight: FontWeight.w700),
                          onPressed: () =>
                              _controller.joinRaffle(_activeRaffleId),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isAllCompleted
                                    ? "Raffle completed! Download prize above."
                                    : "Entered ($completedTasks/${tasks.length} completed). Finish tasks to win!",
                                style: AppTextStyle.textXs(
                                  weight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              )
            : null,
      );
    });
  }
}

class _RaffleDetailsContent extends StatelessWidget {
  const _RaffleDetailsContent({
    required this.details,
    required this.controller,
    required this.raffleId,
    required this.onTaskTap,
  });

  final RaffleDetailsModel details;
  final RaffleDetailsController controller;
  final String raffleId;
  final void Function(RaffleTaskModel task) onTaskTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final raffle = details.raffleModel;
    final tasks = details.tasks;
    final sponsor = details.sponsor;

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final isAllCompleted = totalTasks > 0 && completedTasks == totalTasks;
    final progressValue = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    final dateRange =
        '${DateParserHelper.shortDate(DateTime.parse(raffle.startDate))} - '
        '${DateParserHelper.shortDate(DateTime.parse(raffle.endDate))}';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Compact Hero Card ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: isDark ? 0.25 : 0.12),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CustomCachedImage(
                      imageUrl: raffle.banner,
                      height: 145,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: 0,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Badges row
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            spacing: 6,
                            children: [
                              if (details.status.isNotEmpty)
                                ExploreActivityStatusBadge(status: details.status),
                              ExploreActivityVisibilityBadge(isPublic: details.isPublic),
                            ],
                          ),
                          if (details.isParticipating)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "Entered",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        raffle.title,
                        style: AppTextStyle.textLg(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (raffle.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          raffle.description,
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateRange,
                            style: AppTextStyle.textXs(
                              weight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          if (raffle.maxSupply > 0) ...[
                            const SizedBox(width: 14),
                            Icon(
                              Icons.confirmation_num_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${raffle.maxSupply} max entries',
                              style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── 2. Prize Showcase Card with Direct Prize Image Gallery Download ───
          _CompactPrizeSection(
            prizeName: raffle.bundleName,
            prizeImage: raffle.rafflePrizeImage,
            raffleTitle: raffle.title,
            sponsorName: sponsor.name,
            voucherCode: details.voucherCode,
            isCompleted: isAllCompleted,
            isParticipating: details.isParticipating,
          ),

          const SizedBox(height: 14),

          // ── 3. Your Progress Card ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${(progressValue * 100).toInt()}% ($completedTasks/$totalTasks completed)',
                      style: AppTextStyle.textXs(
                        weight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: progressValue.clamp(0.0, 1.0),
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                  progressColor: isAllCompleted ? const Color(0xFF10B981) : colorScheme.primary,
                  barRadius: const Radius.circular(8),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── 4. Entry Tasks Section ────────────────────────────────────────
          Text(
            'Entry Requirements',
            style: AppTextStyle.textSm(
              weight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            details.isParticipating
                ? 'Complete each task to enter the raffle draw'
                : 'Enter the raffle below to unlock tasks',
            style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No entry requirements for this raffle.',
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final activity = task.activity;
                final isLocked = !details.isParticipating && !task.isCompleted;

                return _CompactTaskTile(
                  step: task.order,
                  typeLabel: task.isRouteTask ? 'Route' : 'Event',
                  title: activity?.title.isNotEmpty == true
                      ? activity!.title
                      : 'Activity #${task.order}',
                  imageUrl: activity?.banner,
                  isCompleted: task.isCompleted,
                  isLocked: isLocked,
                  onTap: task.isCompleted
                      ? null
                      : () {
                          if (!details.isParticipating) {
                            SnackbarService.warning(
                              'Please enter the raffle first to start completing tasks.',
                            );
                            return;
                          }
                          onTaskTap(task);
                        },
                );
              },
            ),

          const SizedBox(height: 14),

          // ── 5. Sponsor Tile ───────────────────────────────────────────────
          if (sponsor.name.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
                ),
              ),
              child: Row(
                children: [
                  BusinessAvatar(
                    imageUrl: sponsor.logo,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SPONSORED BY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          sponsor.name,
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sponsor.description.isNotEmpty)
                          Text(
                            sponsor.description,
                            style: AppTextStyle.textXs(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Compact Prize Section with Direct Network Image Download ──────────────

class _CompactPrizeSection extends StatefulWidget {
  const _CompactPrizeSection({
    required this.prizeName,
    this.prizeImage,
    required this.raffleTitle,
    required this.sponsorName,
    this.voucherCode,
    required this.isCompleted,
    required this.isParticipating,
  });

  final String prizeName;
  final String? prizeImage;
  final String raffleTitle;
  final String sponsorName;
  final String? voucherCode;
  final bool isCompleted;
  final bool isParticipating;

  @override
  State<_CompactPrizeSection> createState() => _CompactPrizeSectionState();
}

class _CompactPrizeSectionState extends State<_CompactPrizeSection> {
  bool _isSavingToGallery = false;

  Future<void> _downloadPrizeImage(BuildContext context) async {
    if (_isSavingToGallery) return;

    final imgUrl = widget.prizeImage?.trim() ?? '';
    if (imgUrl.isEmpty) {
      SnackbarService.warning('Prize image is currently unavailable.');
      return;
    }

    setState(() => _isSavingToGallery = true);

    try {
      await GalleryImageDownloader.saveNetworkImage(imgUrl);
      SnackbarService.success('Prize image saved to your gallery successfully.');
    } catch (e) {
      SnackbarService.error(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingToGallery = false);
      }
    }
  }

  void _copyVoucherCode() {
    if (widget.voucherCode != null && widget.voucherCode!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: widget.voucherCode!));
      HapticFeedback.lightImpact();
      SnackbarService.success('Voucher code copied to clipboard.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canDownload = widget.isCompleted && widget.isParticipating;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canDownload
              ? const Color(0xFF10B981).withValues(alpha: 0.45)
              : colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
          width: canDownload ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prize Image / Icon
              if (widget.prizeImage != null && widget.prizeImage!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomCachedImage(
                    imageUrl: widget.prizeImage!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: colorScheme.primary,
                    size: 26,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICIAL PRIZE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.prizeName.isNotEmpty ? widget.prizeName : 'Raffle Prize',
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.sponsorName.isNotEmpty)
                      Text(
                        'By ${widget.sponsorName}',
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
            ],
          ),

          // If Voucher Code is issued
          if (widget.voucherCode != null && widget.voucherCode!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.voucherCode!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: colorScheme.primary,
                    ),
                  ),
                  InkWell(
                    onTap: _copyVoucherCode,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: AppTextStyle.textXs(
                              weight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Download Prize Image Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: canDownload && !_isSavingToGallery
                  ? () => _downloadPrizeImage(context)
                  : null,
              icon: _isSavingToGallery
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      canDownload ? Icons.download_rounded : Icons.lock_outline_rounded,
                      size: 16,
                    ),
              label: Text(
                _isSavingToGallery
                    ? 'Saving Prize Image...'
                    : (canDownload
                        ? 'Download Prize Image'
                        : (widget.isParticipating
                            ? 'Complete all tasks to download'
                            : 'Enter raffle to unlock prize')),
                style: AppTextStyle.textXs(weight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canDownload ? const Color(0xFF10B981) : colorScheme.surfaceContainerHighest,
                foregroundColor: canDownload ? Colors.white : colorScheme.onSurfaceVariant,
                disabledBackgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                elevation: canDownload ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compact Task Tile ─────────────────────────────────────────────────────

class _CompactTaskTile extends StatelessWidget {
  final int step;
  final String typeLabel;
  final String title;
  final String? imageUrl;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;

  const _CompactTaskTile({
    required this.step,
    required this.typeLabel,
    required this.title,
    this.imageUrl,
    required this.isCompleted,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: isLocked ? 0.65 : 1.0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
            ),
          ),
          child: Row(
            children: [
              // Step / Checkmark circle
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : (isLocked
                          ? colorScheme.outline.withValues(alpha: 0.2)
                          : colorScheme.primaryContainer),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : (isLocked
                          ? Icon(Icons.lock_rounded, size: 13, color: colorScheme.onSurfaceVariant)
                          : Text(
                              '$step',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            )),
                ),
              ),
              const SizedBox(width: 10),

              // Image Thumbnail
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomCachedImage(
                    imageUrl: imageUrl!,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Task Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status Tag
              if (isCompleted)
                const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                )
              else if (isLocked)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
