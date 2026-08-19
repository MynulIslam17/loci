import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/data/models/activity_attendee_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/total_rsvp_controller.dart';
import 'package:loci/shared/widgets/adaptive_expandable_search_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

class TotalRsvpScreen extends StatefulWidget {
  const TotalRsvpScreen({super.key});

  @override
  State<TotalRsvpScreen> createState() => _TotalRsvpScreenState();
}

class _TotalRsvpScreenState extends State<TotalRsvpScreen> {
  late String title;
  late final TotalRsvpController _controller;
  final _searchController = TextEditingController();

  final FocusNode _searchFocus = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<TotalRsvpController>()) {
      _controller = Get.find<TotalRsvpController>();
    } else {
      _controller =
          Get.put(TotalRsvpController(Get.find<ExploreActivityService>()));
    }

    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title']?.toString() ?? 'Total RSVP List';

    String? eventId = args?['eventId']?.toString();
    if (eventId == null || eventId.isEmpty) {
      if (Get.isRegistered<BusinessEventDetailsController>()) {
        eventId = Get.find<BusinessEventDetailsController>()
            .eventDetails
            .value
            ?.eventModel
            .id;
      }
    }

    if (eventId != null && eventId.isNotEmpty) {
      _controller.initForEvent(eventId);
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: title),
      body: AdaptiveRefresh(
        onRefresh: () => _controller.fetchRsvpList(isRefresh: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Obx(
                    () => AdaptiveExpandableSearchHeader(
                      title: "Total RSVP list",
                      subtitle: "${_controller.totalCount} Leads",
                      hintText: "Search RSVP attendees...",
                      padding: EdgeInsets.zero,
                      searchController: _searchController,
                      searchFocus: _searchFocus,
                      isExpanded: _isSearchExpanded,
                      onToggleExpand: (expanded) {
                        setState(() => _isSearchExpanded = expanded);
                      },
                      onSearchChanged: _controller.onSearchChanged,
                      onClear: () {
                        _controller.onSearchChanged('');
                      },
                      trailing: OutlinedButton.icon(
                        onPressed: _controller.isExporting
                            ? null
                            : _controller.exportCsv,
                        icon: _controller.isExporting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.save_alt,
                                size: 18,
                                color: colorScheme.onSurface,
                              ),
                        label: Text(
                          _controller.isExporting ? "Saving..." : "Save",
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurface,
                            weight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Attendee List ---
              Obx(() {
                if (_controller.isLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (_controller.errorMessage != null) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _controller.errorMessage!,
                            style: AppTextStyle.textSm(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _controller.fetchRsvpList(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final attendees = _controller.attendees;
                if (attendees.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        "No RSVP attendees found",
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final attendee = attendees[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _buildAttendeeCard(context, attendee),
                      );
                    },
                    childCount: attendees.length,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(
    BuildContext context,
    RsvpAttendeeModel attendee,
  ) {
    final colorScheme = context.colorScheme;
    final statusColor = attendee.status.toLowerCase() == 'going'
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomCachedImage(
              width: 48,
              height: 48,
              imageUrl: attendee.avatar,
              isCircle: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          attendee.name,
                          style: AppTextStyle.textSm(weight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          attendee.status.capitalizeFirst ?? attendee.status,
                          style: AppTextStyle.textXs(
                            color: statusColor,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (attendee.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.email_outlined,
                      attendee.email,
                    ),
                  ],
                  if (attendee.formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      attendee.formattedDate,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.textXs(
              color: context.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
