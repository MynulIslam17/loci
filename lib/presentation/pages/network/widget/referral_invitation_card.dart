import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import '../../../../core/enums/referral_enum.dart';

class ReferralInvitationCard extends StatelessWidget {
  final ReferralStatus status;
  final String recipientName;
  final String recipientEmail;
  final String referredByName;
  final String referredByEmail;
  final String message;
  final String date;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool isAccepting;
  final bool isRejecting;

  const ReferralInvitationCard({
    super.key,
    required this.status,
    required this.recipientName,
    required this.recipientEmail,
    required this.referredByName,
    required this.referredByEmail,
    required this.message,
    required this.date,
    required this.onConfirm,
    required this.onReject,
    this.isAccepting = false,
    this.isRejecting = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ── Header: Status + Date ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: _buildStatusBadge(context)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    date,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ── Recipient ← Referred by ───────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPersonInfo(
                    context,
                    label: 'Recipient',
                    name: recipientName,
                    email: recipientEmail,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: _buildPersonInfo(
                    context,
                    label: 'Referred by',
                    name: referredByName,
                    email: referredByEmail,
                    alignRight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ── Message Bubble ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$message"',
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),
            ),

            /// ── Action Buttons (pending only) ─────────────────────────────
            if (status == ReferralStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: onConfirm,
                      isLoading: isAccepting,
                      child: Text(
                        'Confirm',
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: onReject,
                      isLoading: isRejecting,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.red),
                      child: Text(
                        'Reject',
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

          ],
        ),
      ),
    );
  }

  /// ── Status Badge ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(BuildContext context) {
    late Color bgColor;
    late Color textColor;
    late IconData icon;

    switch (status) {
      case ReferralStatus.sent:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.send;
        break;
      case ReferralStatus.pending:
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade700;
        icon = Icons.access_time_filled;
        break;
      case ReferralStatus.accepted:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case ReferralStatus.confirmed:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case ReferralStatus.rejected:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.textXs(
                color: textColor,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Person Info ───────────────────────────────────────────────────────────
  Widget _buildPersonInfo(
    BuildContext context, {
    required String label,
    required String name,
    required String email,
    bool alignRight = false,
  }) {
    final colorScheme = context.colorScheme;
    final align =
        alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignRight ? TextAlign.end : TextAlign.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: AppTextStyle.textXs(
            color: colorScheme.onSurfaceVariant,
            weight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: AppTextStyle.textXs(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
