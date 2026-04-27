import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/metting_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';

class MeetingCard extends StatelessWidget {
  final MeetingStatus status;
  final String fromName;
  final String fromCompany;
  final String toName;
  final String toCompany;
  final String location;
  final String time;
  final String message;
  final String date;

  const MeetingCard({
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
            // HEADER
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

            // PEOPLE
            Row(
              children: [
                Expanded(
                  child: _buildPersonInfo(
                    context,
                    fromName,
                    fromCompany,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
                Expanded(
                  child: _buildPersonInfo(
                    context,
                    toName,
                    toCompany,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // LOCATION + TIME
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

            // MESSAGE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _buildStatusBadge(BuildContext context) {
    late Color bgColor;
    late Color textColor;
    late IconData icon;
    late String text;

    switch (status) {
      case MeetingStatus.pending:
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        icon = Icons.access_time;
        text = "Pending";
        break;

      case MeetingStatus.confirmed:
        bgColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        icon = Icons.check_circle;
        text = "Confirmed";
        break;

      case MeetingStatus.rejected:
        bgColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red;
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

  // ================= PERSON =================
  Widget _buildPersonInfo(
      BuildContext context,
      String name,
      String company,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.textSm(weight: FontWeight.w700),
        ),
        Text(
          company,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ================= ICON LABEL =================
  Widget _buildIconLabel(
      BuildContext context,
      IconData icon,
      String label,
      ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.textXs(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}