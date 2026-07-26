import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/network/presentation/controllers/incoming_meetings_controller.dart';
import 'package:loci/features/network/presentation/controllers/respond_meeting_controller.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/features/network/presentation/widgets/meeting_invitation_card.dart';
import 'package:loci/features/network/presentation/widgets/meeting_shimmer.dart';

String _filteredEmptyTitle(DateTime? date) {
  if (date == null) return 'No meeting invitations yet';
  return 'No invitations on ${DateParserHelper.toFriendlyDate(date)}';
}

class ReceivedMeetingsTab extends StatefulWidget {
  const ReceivedMeetingsTab({super.key});

  @override
  State<ReceivedMeetingsTab> createState() => _ReceivedMeetingsTabState();
}

class _ReceivedMeetingsTabState extends State<ReceivedMeetingsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final controller = Get.find<IncomingMeetingsController>();
    return Obx(() {
      if (controller.isLoading) {
        return const MeetingShimmer();
      }

      if (controller.errorMessage != null && controller.meetings.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.fetchIncomingMeetings,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: ErrorStateWidget(
                  message: controller.errorMessage!,
                  onRetry: controller.fetchIncomingMeetings,
                ),
              ),
            ),
          ),
        );
      }

      if (controller.meetings.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.fetchIncomingMeetings,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: _filteredEmptyTitle(controller.selectedDate),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchIncomingMeetings,
        child: ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount:
              controller.meetings.length + (controller.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.meetings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final m = controller.meetings[index];
            final fromCompany = m.requester.company.isNotEmpty
                ? m.requester.company
                : m.requester.email;

            final respondCtrl = Get.find<RespondMeetingController>();
            return Obx(() {
              final responding = respondCtrl.isResponding(m.id);
              return MeetingInvitationCard(
                status: m.status,
                fromName: m.requester.name,
                fromCompany: fromCompany,
                toName: m.recipient.name,
                toCompany: m.recipient.email,
                location: m.location,
                time: m.meetingTime,
                message: m.message,
                date: DateParserHelper.toFriendlyDate(
                  DateParserHelper.parseDate(m.meetingDate),
                ),
                isConfirming: respondCtrl.isConfirming(m.id),
                isRejecting: respondCtrl.isRejecting(m.id),
                onConfirm: responding
                    ? null
                    : () => respondCtrl.respond(
                        m.id,
                        RespondMeetingController.confirmAction,
                      ),
                onReject: responding
                    ? null
                    : () => respondCtrl.respond(
                        m.id,
                        RespondMeetingController.rejectAction,
                      ),
              );
            });
          },
          separatorBuilder: (_, __) => const SizedBox(height: 15),
        ),
      );
    });
  }
}
