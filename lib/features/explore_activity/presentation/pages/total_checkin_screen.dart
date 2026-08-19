import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/data/models/activity_attendee_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/total_checkin_controller.dart';
import 'package:loci/shared/widgets/adaptive_expandable_search_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

class TotalCheckInScreen extends StatefulWidget {
  const TotalCheckInScreen({super.key});

  @override
  State<TotalCheckInScreen> createState() => _TotalCheckInScreenState();
}

class _TotalCheckInScreenState extends State<TotalCheckInScreen> {
  late String title;
  late final TotalCheckinController _controller;
  final _searchController = TextEditingController();

  final FocusNode _searchFocus = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<TotalCheckinController>()) {
      _controller = Get.find<TotalCheckinController>();
    } else {
      _controller =
          Get.put(TotalCheckinController(Get.find<ExploreActivityService>()));
    }

    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title']?.toString() ?? 'Total Check-Ins';

    String? entityId = args?['entityId']?.toString() ??
        args?['eventId']?.toString() ??
        args?['routeId']?.toString();
    String type = args?['type']?.toString().toLowerCase() ?? 'event';

    if (entityId == null || entityId.isEmpty) {
      if (type == 'route' &&
          Get.isRegistered<BusinessRouteDetailsController>()) {
        entityId = Get.find<BusinessRouteDetailsController>()
            .routeDetails
            .value
            ?.routeModel
            .routeId;
      } else if (Get.isRegistered<BusinessEventDetailsController>()) {
        entityId = Get.find<BusinessEventDetailsController>()
            .eventDetails
            .value
            ?.eventModel
            .id;
        type = 'event';
      }
    }

    if (entityId != null && entityId.isNotEmpty) {
      _controller.initForActivity(entityId: entityId, type: type);
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
        onRefresh: () => _controller.fetchCheckins(isRefresh: true),
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
                      title: "Total Check-Ins",
                      subtitle: "${_controller.totalCount} Leads",
                      hintText: "Search check-ins contacts...",
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
                            onPressed: () => _controller.fetchCheckins(),
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
                        "No check-ins found",
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
    CheckInAttendeeModel attendee,
  ) {
    final colorScheme = context.colorScheme;

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
                  Text(
                    attendee.name,
                    style: AppTextStyle.textSm(weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attendee.company.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.business_outlined,
                      attendee.company,
                    ),
                  ],
                  if (attendee.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.email_outlined,
                      attendee.email,
                    ),
                  ],
                  if (attendee.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.phone_outlined,
                      attendee.phone,
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
