import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/network/data/models/referral_response_model.dart';
import 'package:loci/features/network/presentation/widgets/network_card_helpers.dart';
import 'package:loci/features/network/presentation/widgets/network_person_block.dart';
import 'package:loci/features/network/presentation/widgets/network_status_badge.dart';

class ReferralCard extends StatelessWidget {
  const ReferralCard({super.key, required this.referral});

  final ReferralModel referral;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final date = DateParserHelper.eventDateTime(
      DateParserHelper.parseDate(referral.createdAt)?.toLocal(),
    );

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
              NetworkStatusBadge.referral(referral.status),
              const Spacer(),
              Text(
                date,
                style: AppTextStyle.textXs(
                  color: colors.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NetworkPersonBlock(
            role: 'Recipient',
            name: referral.recipient.fullName,
            email: referral.recipient.email,
            company: referral.recipient.companyName,
            accent: colors.primary,
          ),
          const NetworkConnector(),
          NetworkPersonBlock(
            role: 'Business owner',
            name: referral.businessOwner.fullName,
            email: referral.businessOwner.email,
            company: referral.businessOwner.companyName,
            accent: colors.tertiary,
          ),
          if (referral.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            NetworkMessageBubble(message: referral.message),
          ],
        ],
      ),
    );
  }
}
