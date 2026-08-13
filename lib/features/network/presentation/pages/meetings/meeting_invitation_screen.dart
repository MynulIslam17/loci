import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/meeting_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/data/models/meeting_models.dart';
import 'package:loci/features/network/presentation/widgets/meetings/meeting_invitation_card.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

class MeetingInvitationScreen extends StatefulWidget {
  const MeetingInvitationScreen({super.key});

  @override
  State<MeetingInvitationScreen> createState() =>
      _MeetingInvitationScreenState();
}

class _MeetingInvitationScreenState extends State<MeetingInvitationScreen> {
  static IncomingMeetingModel _mockMeeting(MeetingStatus status) {
    return IncomingMeetingModel(
      id: 'mock',
      requester: MeetingRequester(
        id: '1',
        name: 'Alice Johnson',
        email: 'alice@techcorp.com',
        avatar: '',
        company: 'TechCorp',
      ),
      recipient: MeetingRecipient(
        name: 'Michael Chen',
        email: 'michael@innovatelabs.com',
      ),
      meetingDate: '2026-03-15',
      meetingTime: '12:30 PM',
      location: 'Downtown Conference Room',
      message: 'Discuss Q2 roadmap and align on team objectives.',
      status: status,
      createdAt: '',
      updatedAt: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Meeting Invitations"),
      body: CustomScrollView(
        slivers: [
          /// ── Header ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Meeting Requests",
                    style: AppTextStyle.textLg(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Review the details and respond to confirm or reject.",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ── List ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: 5,
              itemBuilder: (context, index) {
                final status = index.isEven
                    ? MeetingStatus.pending
                    : MeetingStatus.confirmed;
                return MeetingInvitationCard(
                  meeting: _mockMeeting(status),
                  onConfirm: () {},
                  onReject: () {},
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 12),
            ),
          ),
        ],
      ),
    );
  }
}
