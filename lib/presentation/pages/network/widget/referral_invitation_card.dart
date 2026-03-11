import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/status.dart';

class ReferralInvitationCard extends StatelessWidget {
  final ReferralStatus status;
  final String fromName;
  final String fromCompany;
  final String toName;
  final String toCompany;
  final String location;
  final String time;
  final String message;
  final String date;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const ReferralInvitationCard({
    super.key,
    required this.status,
    required this.fromName,
    required this.fromCompany,
    required this.toName,
    required this.toCompany,
    required this.location,
    required this.time,
    required this.message,
    required this.date,
    required this.onConfirm,
    required this.onReject,
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
            /// Header (Status + Date)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context),
                Text(
                  date,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Referral Flow
            Row(
              children: [
                Expanded(child: _buildPersonInfo(context, fromName, fromCompany)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                Expanded(child: _buildPersonInfo(context, toName, toCompany)),
              ],
            ),

            const SizedBox(height: 12),

            /// Location + Time
            Row(
              children: [
                Expanded(
                  child: _buildIconLabel(
                    context,
                    Icons.location_on_outlined,
                    location,
                  ),
                ),
                Expanded(
                  child: _buildIconLabel(
                    context,
                    Icons.access_time,
                    time,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Message Bubble
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

            /// Action Buttons (only when pending)
            if (status == ReferralStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Confirm"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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

  /// Status Badge
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

      case ReferralStatus.confirm:
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
          Text(
            text,
            style: AppTextStyle.textXs(
              color: textColor,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Person Info
  Widget _buildPersonInfo(BuildContext context, String name, String company) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          company,
          style: AppTextStyle.textXs(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Icon + Label Row
  Widget _buildIconLabel(BuildContext context, IconData icon, String label) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}