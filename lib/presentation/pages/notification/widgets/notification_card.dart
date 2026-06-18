import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../../core/utils/time_parser.dart';
import '../../../../data/models/notification/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: notification.isRead
            ? colorScheme.surfaceContainerHigh
            : colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TypeIcon(type: notification.type),
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
                              Text(formatRelativeTime(notification.createdAt)),
                              if (!notification.isRead) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
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
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (notification.actionRequired) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF62B4AC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Confirm",
                            style: AppTextStyle.textSm(
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Reject",
                            style: AppTextStyle.textSm(
                              color: Colors.redAccent,
                              weight: FontWeight.w600,
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
        ),
      ),
    );
  }

}


class TypeIcon extends StatelessWidget {
  final String type;

  const TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final t = type.toLowerCase();

    final IconData icon;
    final Color bg;
    final Color fg;

    if (t.contains('referral')) {
      icon = Icons.share_outlined;
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade700;
    } else if (t.contains('meeting')) {
      icon = Icons.event_outlined;
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
    } else if (t.contains('community')) {
      icon = Icons.group_outlined;
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    } else if (t.contains('answer') || t.contains('comment')) {
      icon = Icons.chat_bubble_outline;
      bg = Colors.purple.shade50;
      fg = Colors.purple.shade700;
    } else {
      icon = Icons.notifications_outlined;
      bg = colorScheme.primaryContainer;
      fg = colorScheme.primary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}