import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/network/widget/referral_invitation_card.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';

import '../../../core/utils/status.dart';
import 'widget/referral_card.dart';

class ReferralsInvitationScreen extends StatefulWidget {
  const ReferralsInvitationScreen({super.key});

  @override
  State<ReferralsInvitationScreen> createState() =>
      _ReferralsInvitationScreenState();
}

class _ReferralsInvitationScreenState extends State<ReferralsInvitationScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: "Referral Invitations"),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Referral Requests",
                style: AppTextStyle.textLg(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
        
              const SizedBox(height: 2),
              Text(
                "You have received referral invitations. Review them and decide whether to accept or reject.",
                style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
              ),
        
              const SizedBox(height: 20),
        
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ReferralInvitationCard(
                    status: ReferralStatus.pending,
                    fromName: "Sarah ",
                    fromCompany: "TechCorp",
                    toName: "Michael Chen",
                    toCompany: "Innovate Labs",
                    location: "Downtown District",
                    time: "12:30 PM",
                    message: "Let's do meeting about our future plan for the company's new profit share!",
                    date: "Jan 29, 2025",
                    onConfirm: () {
                      // Add your confirmation logic here
                      print("Confirmed");
                    },
                    onReject: () {
                      // Add your rejection logic here
                      print("Rejected");
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



}
