import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/status.dart';

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
    return Card(
      color: context.colorScheme.surfaceContainerHigh,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline,
                          size: 12, color: _getLabelColor(status)),
                      const SizedBox(width: 4),
                      Text(
                        getReferralStatus(status),
                        style: AppTextStyle.textXs(
                            color: _getLabelColor(status),
                            weight: FontWeight.w600),
                      ),
                    ]),
                  ),
                ),
                Text(date,
                    style: AppTextStyle.textXs(
                        color: context.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),

            // Referral Flow (Person A -> Person B)
            // Using Expanded on both sides to ensure they share space equally
            Row(
              children: [
                Expanded(child: _buildPersonInfo(context, fromName, fromCompany)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 20),
                ),
                Expanded(child: _buildPersonInfo(context, toName, toCompany)),
              ],
            ),
            const SizedBox(height: 16),

            // Message Bubble
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$message"',
                style: AppTextStyle.textXs(
                    color: context.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonInfo(BuildContext context, String name, String company) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Adds "..." if name is too long
          style: AppTextStyle.textSm(
              weight: FontWeight.w600, color: context.colorScheme.onSurface),
        ),
        Text(
          company,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Adds "..." if company is too long
          style: AppTextStyle.textXs(
              color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Color _getLabelColor(ReferralStatus status) {
    return switch (status) {
      ReferralStatus.sent => Colors.green,
      ReferralStatus.pending => Colors.yellow,
      ReferralStatus.rejected => Colors.red,
    };
  }
}