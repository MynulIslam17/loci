import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/explore_activity/data/models/activity_attendee_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffle_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/total_participants_controller.dart';
import 'package:loci/shared/widgets/adaptive_expandable_search_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

class TotalParticipantsScreen extends StatefulWidget {
  const TotalParticipantsScreen({super.key});

  @override
  State<TotalParticipantsScreen> createState() =>
      _TotalParticipantsScreenState();
}

class _TotalParticipantsScreenState extends State<TotalParticipantsScreen> {
  late String title;
  late final TotalParticipantsController _controller;
  final _searchController = TextEditingController();

  final FocusNode _searchFocus = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<TotalParticipantsController>()) {
      _controller = Get.find<TotalParticipantsController>();
    } else {
      _controller = Get.put(
        TotalParticipantsController(Get.find<ExploreActivityService>()),
      );
    }

    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title']?.toString() ?? 'Raffle Participants';

    String? raffleId = args?['raffleId']?.toString();
    if (raffleId == null || raffleId.isEmpty) {
      if (Get.isRegistered<BusinessRaffleDetailsController>()) {
        raffleId = Get.find<BusinessRaffleDetailsController>()
            .raffleDetails
            .value
            ?.raffleModel
            .id;
      }
    }

    if (raffleId != null && raffleId.isNotEmpty) {
      _controller.initForRaffle(raffleId);
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
        onRefresh: () => _controller.fetchParticipants(isRefresh: true),
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
                      title: "Total participants",
                      subtitle: "${_controller.totalCount} Leads",
                      hintText: "Search participants...",
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

              // --- Participant List ---
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
                            onPressed: () => _controller.fetchParticipants(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final participants = _controller.participants;
                if (participants.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        "No raffle participants found",
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
                      final item = participants[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _buildParticipantCard(context, item),
                      );
                    },
                    childCount: participants.length,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    RaffleParticipantAttendeeModel item,
  ) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isCompleted = item.isCompleted;
    final statusColor =
        isCompleted ? const Color(0xFF10B981) : colorScheme.primary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedImage(
              width: 46,
              height: 46,
              imageUrl: item.avatar,
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
                          item.name,
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
                          isCompleted
                              ? 'Completed'
                              : '${item.completionPercentage}%',
                          style: AppTextStyle.textXs(
                            color: statusColor,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.email_outlined,
                      item.email,
                    ),
                  ],
                  if (item.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.phone_outlined,
                      item.phone,
                    ),
                  ],
                  if (item.voucherCode != null &&
                      item.voucherCode!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: item.voucherCode!),
                        );
                        HapticFeedback.lightImpact();
                        SnackbarService.success('Voucher code copied to clipboard.');
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.confirmation_num_outlined,
                              size: 13,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.voucherCode!,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.copy_rounded,
                              size: 11,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (item.formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Joined: ${item.formattedDate}',
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
