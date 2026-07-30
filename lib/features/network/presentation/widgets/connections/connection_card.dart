import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/presentation/widgets/network_detail_row.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// A single network connection with avatar and contact details.
class ConnectionCard extends StatelessWidget {
  const ConnectionCard({super.key, required this.connection});

  final ConnectionModel connection;

  String? get _connectedLabel {
    final date = DateParserHelper.parseDate(connection.connectedAt)?.toLocal();
    if (date == null) return null;
    return DateParserHelper.eventDateTime(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            width: 48,
            height: 48,
            imageUrl: connection.avatar,
            isCircle: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        connection.name,
                        softWrap: true,
                        style: AppTextStyle.textSm(
                          color: colors.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_connectedLabel != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _connectedLabel!,
                        style: AppTextStyle.textXs(
                          color: colors.onSurfaceVariant,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (connection.organization.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  NetworkDetailRow(
                    icon: Icons.business_outlined,
                    text: connection.organization,
                  ),
                ],
                if (connection.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  NetworkDetailRow(
                    icon: Icons.mail_outline,
                    text: connection.email,
                  ),
                ],
                if (connection.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  NetworkDetailRow(
                    icon: Icons.phone_outlined,
                    text: connection.phone,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
