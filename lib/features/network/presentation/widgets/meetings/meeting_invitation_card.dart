import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/meeting_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/network/data/models/meeting_models.dart';
import 'package:loci/features/network/presentation/widgets/network_card_helpers.dart';
import 'package:loci/features/network/presentation/widgets/network_detail_row.dart';
import 'package:loci/features/network/presentation/widgets/network_person_block.dart';
import 'package:loci/features/network/presentation/widgets/network_status_badge.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class MeetingInvitationCard extends StatelessWidget {
  const MeetingInvitationCard({
    super.key,
    required this.meeting,
    required this.onConfirm,
    required this.onReject,
    this.isConfirming = false,
    this.isRejecting = false,
  });

  final IncomingMeetingModel meeting;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool isConfirming;
  final bool isRejecting;

  String get _dateLabel {
    final date = DateParserHelper.parseDate(meeting.meetingDate);
    if (date == null) return meeting.meetingDate;
    return DateParserHelper.toFriendlyDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final requesterCompany = meeting.requester.company.isNotEmpty
        ? meeting.requester.company
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetworkStatusBadge.meeting(meeting.status),
              const Spacer(),
              Text(
                _dateLabel,
                style: AppTextStyle.textXs(
                  color: colors.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NetworkPersonBlock(
            role: 'From',
            name: meeting.requester.name,
            email: meeting.requester.email,
            company: requesterCompany,
            accent: colors.primary,
          ),
          const NetworkConnector(),
          NetworkPersonBlock(
            role: 'Recipient',
            name: meeting.recipient.name,
            email: meeting.recipient.email,
            accent: colors.tertiary,
          ),
          const SizedBox(height: 10),
          if (meeting.location.isNotEmpty)
            NetworkDetailRow(
              icon: Icons.location_on_outlined,
              text: meeting.location,
              iconColor: colors.primary,
            ),
          if (meeting.meetingTime.isNotEmpty) ...[
            const SizedBox(height: 4),
            NetworkDetailRow(
              icon: Icons.access_time,
              text: meeting.meetingTime,
              iconColor: colors.primary,
            ),
          ],
          if (meeting.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            NetworkMessageBubble(message: meeting.message),
          ],
          if (meeting.status == MeetingStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: onConfirm,
                    isLoading: isConfirming,
                    height: 42,
                    child: Text(
                      'Confirm',
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w600,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    onPressed: onReject,
                    isLoading: isRejecting,
                    height: 42,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: colors.error.withValues(alpha: 0.7)),
                    child: Text(
                      'Reject',
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w600,
                        color: colors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
