import 'package:flutter/material.dart';
import 'package:loci/core/enums/notification_type.dart';
import 'package:loci/core/theme/theme_extention.dart';

class NotificationTypeIcon extends StatelessWidget {
  const NotificationTypeIcon({super.key, required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final (IconData icon, Color bg, Color fg) = switch (type) {
      NotificationType.referralReceived ||
      NotificationType.referralAccepted ||
      NotificationType.referralRejected => (
        Icons.share_outlined,
        Colors.blue.shade50,
        Colors.blue.shade700,
      ),
      NotificationType.meetingRequest ||
      NotificationType.meetingConfirmed ||
      NotificationType.meetingRejected => (
        Icons.event_outlined,
        Colors.orange.shade50,
        Colors.orange.shade700,
      ),
      NotificationType.communityMemberInvite => (
        Icons.group_outlined,
        Colors.green.shade50,
        Colors.green.shade700,
      ),
      NotificationType.questionAnswered => (
        Icons.help_outline_rounded,
        Colors.purple.shade50,
        Colors.purple.shade700,
      ),
      NotificationType.newMessage => (
        Icons.chat_bubble_outline,
        Colors.teal.shade50,
        Colors.teal.shade700,
      ),
      NotificationType.eventRsvp => (
        Icons.event_available_outlined,
        Colors.indigo.shade50,
        Colors.indigo.shade700,
      ),
      NotificationType.raffleCompleted => (
        Icons.card_giftcard_outlined,
        Colors.pink.shade50,
        Colors.pink.shade700,
      ),
      NotificationType.businessClaimSubmitted ||
      NotificationType.businessClaimApproved => (
        Icons.storefront_outlined,
        Colors.brown.shade50,
        Colors.brown.shade700,
      ),
      NotificationType.unknown => (
        Icons.notifications_outlined,
        colorScheme.primaryContainer,
        colorScheme.primary,
      ),
    };

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
