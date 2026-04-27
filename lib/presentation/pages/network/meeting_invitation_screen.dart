import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/network/widget/meeting_invitation_card.dart';
import '../../../core/utils/status.dart';
import '../../widgets/custom_appbar.dart';


class MeetingInvitationScreen extends StatefulWidget {
  const MeetingInvitationScreen({super.key});

  @override
  State<MeetingInvitationScreen> createState() => _MeetingInvitationScreenState();
}

class _MeetingInvitationScreenState extends State<MeetingInvitationScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Meeting Invitations"),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- Screen Title ---
              Text(
                "Meetings Requests",
                style: AppTextStyle.textLg(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              // --- Screen Description ---
              Text(
                "Here are your meeting invitations. Review the details and respond to confirm or reject the meeting.",
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // --- Meeting Invitations List ---
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5, // Example count
                itemBuilder: (context, index) {
                  return MeetingInvitationCard(
                    status: index % 3 == 0 ? ReferralStatusEnum.pending : ReferralStatusEnum.confirm,
                    fromName: "Alice Johnson",
                    fromCompany: "TechCorp",
                    toName: "Michael Chen",
                    toCompany: "Innovate Labs",
                    location: "Downtown Conference Room",
                    time: "12:30 PM",
                    message: "Discuss Q2 roadmap and align on team objectives.",
                    date: "Mar 15, 2026",
                    onConfirm: () {
                      print("Meeting Confirmed");
                    },
                    onReject: () {
                      print("Meeting Rejected");
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}