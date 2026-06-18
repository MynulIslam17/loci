import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/theme_extention.dart';
import '../../../../../core/utils/date_parser.dart';
import '../../../../controllers/network_dash/sent_meetings_controller.dart';
import '../../../../widgets/empty_state.dart';
import '../../widget/meeting_card.dart';
import '../../widget/meeting_shimmer.dart';

String _filteredEmptyTitle(DateTime? date) {
  if (date == null) return 'No sent meetings yet';
  return 'No sent meetings on ${DateParserHelper.toFriendlyDate(date)}';
}

class SentMeetingsTab extends StatefulWidget {
  const SentMeetingsTab({super.key});

  @override
  State<SentMeetingsTab> createState() => _SentMeetingsTabState();
}

class _SentMeetingsTabState extends State<SentMeetingsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final color = context.colorScheme;

    return GetBuilder<SentMeetingsController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const MeetingShimmer();
        }

        if (controller.errorMessage != null && controller.meetings.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchSentMeetings,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Text(
                      controller.errorMessage!,
                      style: AppTextStyle.textSm(color: color.error),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (controller.meetings.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchSentMeetings,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: EmptyState(
                      icon: Icons.send_outlined,
                      title: _filteredEmptyTitle(controller.selectedDate),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchSentMeetings,
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
              return MeetingCard(
                status: m.status,
                fromName: 'You',
                fromCompany: '',
                toName: m.recipient.name,
                toCompany: m.recipient.email,
                location: m.location,
                time: m.meetingTime,
                message: m.message,
                date: DateParserHelper.toFriendlyDate(
                  DateParserHelper.parseDate(m.meetingDate),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 15),
          ),
        );
      },
    );
  }
}
