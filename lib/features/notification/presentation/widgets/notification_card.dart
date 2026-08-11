import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';
import 'package:loci/features/notification/presentation/utils/notification_navigation.dart';
import 'package:loci/features/notification/presentation/widgets/notification_inline_action_row.dart';
import 'package:loci/features/notification/presentation/widgets/notification_type_icon.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: notification.isRead
              ? colorScheme.surfaceContainerHigh
              : colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? colorScheme.outlineVariant.withValues(alpha: 0.35)
                : colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: notification.isTappable
                ? () => NotificationNavigation.open(notification)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NotificationTypeIcon(type: notification.notificationType),
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
                                    notification.title,
                                    style: AppTextStyle.textSm(
                                      color: colorScheme.onSurface,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatRelativeTime(notification.createdAt),
                                  style: AppTextStyle.textXs(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (!notification.isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant,
                                weight: FontWeight.w500,
                              ),
                            ),
                            if (notification.isTappable) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Tap to view',
                                style: AppTextStyle.textXs(
                                  color: colorScheme.primary,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (notification.showsInlineActions) ...[
                    const SizedBox(height: 12),
                    NotificationInlineActionRow(notification: notification),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
