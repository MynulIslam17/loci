import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/presentation/widgets/network_detail_row.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// A single network connection with avatar and contact details.
class ConnectionCard extends StatelessWidget {
  const ConnectionCard({
    super.key,
    required this.connection,
    this.onRemove,
    this.isRemoving = false,
  });

  final ConnectionModel connection;
  final VoidCallback? onRemove;
  final bool isRemoving;

  String? get _connectedLabel {
    final date = DateParserHelper.parseDate(connection.connectedAt)?.toLocal();
    if (date == null) return null;
    return DateParserHelper.eventDateTime(date);
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Connection',
      message:
          'Are you sure you want to remove ${connection.name} from your network connections?',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      icon: Icons.person_remove_rounded,
      isDestructive: true,
    );

    if (confirmed) {
      onRemove?.call();
    }
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            connection.name,
                            softWrap: true,
                            style: AppTextStyle.textSm(
                              color: colors.onSurface,
                              weight: FontWeight.w700,
                            ),
                          ),
                          if (_connectedLabel != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Connected $_connectedLabel',
                              style: AppTextStyle.textXs(
                                color: colors.onSurfaceVariant,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onRemove != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: isRemoving ? null : () => _confirmRemove(context),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.error.withValues(alpha: 0.25),
                            ),
                          ),
                          child: isRemoving
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.error,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_remove_rounded,
                                      size: 15,
                                      color: colors.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Remove',
                                      style: AppTextStyle.textXs(
                                        color: colors.error,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (connection.organization.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
