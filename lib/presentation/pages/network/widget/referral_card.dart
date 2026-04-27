import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import '../../../../core/enums/referral_enum.dart';

class ReferralCard extends StatelessWidget {
  final ReferralStatus status;
  final String fromName;
  final String fromCompany;
  final String toName;
  final String toCompany;
  final String message;
  final String date;

  const ReferralCard({
    super.key,
    required this.status,
    required this.fromName,
    required this.fromCompany,
    required this.toName,
    required this.toCompany,
    required this.message,
    required this.date,
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

            /// ================= HEADER =================
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

            /// ================= REFERRAL FLOW =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPersonInfo(
                    context,
                    fromName,
                    fromCompany,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),

                Expanded(
                  child: _buildPersonInfo(
                    context,
                    toName,
                    toCompany,
                    alignRight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ================= MESSAGE =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$message"',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= STATUS BADGE =================
  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case ReferralStatus.sent:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.send;
        text = "Sent";
        break;

      case ReferralStatus.pending:
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade700;
        icon = Icons.access_time_filled;
        text = "Pending";
        break;

      case ReferralStatus.confirmed:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        text = "Accepted";
        break;

      case ReferralStatus.rejected:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        text = "Rejected";
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
              text,
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

  /// ================= PERSON INFO =================
  Widget _buildPersonInfo(
      BuildContext context,
      String name,
      String company, {
        bool alignRight = false,
      }) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          company,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
          style: AppTextStyle.textXs(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}