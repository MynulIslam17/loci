import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/referral_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/network/data/models/referral_response_model.dart';
import 'package:loci/features/network/presentation/widgets/network_card_helpers.dart';
import 'package:loci/features/network/presentation/widgets/network_person_block.dart';
import 'package:loci/features/network/presentation/widgets/network_status_badge.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class ReferralInvitationCard extends StatelessWidget {
  const ReferralInvitationCard({
    super.key,
    required this.referral,
    required this.onConfirm,
    required this.onReject,
    this.isAccepting = false,
    this.isRejecting = false,
  });

  final ReferralModel referral;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool isAccepting;
  final bool isRejecting;

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
            role: 'Referred by',
            name: referral.referredBy.fullName,
            email: referral.referredBy.email,
            company: referral.referredBy.companyName,
            accent: colors.tertiary,
          ),
          if (referral.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            NetworkMessageBubble(message: referral.message),
          ],
          if (referral.status == ReferralStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: onConfirm,
                    isLoading: isAccepting,
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
