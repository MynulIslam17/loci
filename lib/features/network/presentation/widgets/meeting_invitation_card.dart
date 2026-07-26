import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/core/enums/meeting_status.dart';

class MeetingInvitationCard extends StatelessWidget {
  final MeetingStatus status;
  final String fromName;
  final String fromCompany;
  final String toName;
  final String toCompany;
  final String location;
  final String time;
  final String message;
  final String date;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool isConfirming;
  final bool isRejecting;

  const MeetingInvitationCard({
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
    this.onConfirm,
    this.onReject,
    this.isConfirming = false,
    this.isRejecting = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                _buildStatusBadge(context),
                Text(
                  date,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ── From → To ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildPersonInfo(context, fromName, fromCompany),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    size: 24,
                  ),
                ),
                Expanded(child: _buildPersonInfo(context, toName, toCompany)),
              ],
            ),

            const SizedBox(height: 12),

            /// ── Location + Time ───────────────────────────────────────────
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
                  child: _buildIconLabel(context, Icons.access_time, time),
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
            if (status == MeetingStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: onConfirm,
                      isLoading: isConfirming,
                      height: 48,
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
                      height: 48,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.red),
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
      case MeetingStatus.sent:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.send;
        break;
      case MeetingStatus.pending:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.access_time_filled;
        break;
      case MeetingStatus.confirmed:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case MeetingStatus.rejected:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        icon = Icons.cancel_outlined;
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
            status.label,
            style: AppTextStyle.textXs(
              color: textColor,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// ── Person Info ───────────────────────────────────────────────────────────
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
        const SizedBox(height: 2),
        Text(
          company,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// ── Icon + Label ──────────────────────────────────────────────────────────
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
            style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
