import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/meeting_status.dart';
import 'package:loci/core/enums/referral_enum.dart';

/// Status pill for meeting and referral cards.
class NetworkStatusBadge extends StatelessWidget {
  const NetworkStatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  factory NetworkStatusBadge.meeting(MeetingStatus status) {
    final style = _meetingStyle(status);
    return NetworkStatusBadge(
      label: status.label,
      icon: style.icon,
      background: style.background,
      foreground: style.foreground,
    );
  }

  factory NetworkStatusBadge.referral(ReferralStatus status) {
    final style = _referralStyle(status);
    return NetworkStatusBadge(
      label: status.label,
      icon: style.icon,
      background: style.background,
      foreground: style.foreground,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyle.textXs(
              color: foreground,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgeStyle _meetingStyle(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.sent:
        return _BadgeStyle(
          Colors.blue.shade50,
          Colors.blue.shade700,
          Icons.send_rounded,
        );
      case MeetingStatus.pending:
        return _BadgeStyle(
          Colors.amber.shade50,
          Colors.amber.shade800,
          Icons.schedule_rounded,
        );
      case MeetingStatus.confirmed:
        return _BadgeStyle(
          Colors.green.shade50,
          Colors.green.shade700,
          Icons.check_circle_rounded,
        );
      case MeetingStatus.rejected:
        return _BadgeStyle(
          Colors.red.shade50,
          Colors.red.shade700,
          Icons.cancel_rounded,
        );
    }
  }

  static _BadgeStyle _referralStyle(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.sent:
        return _BadgeStyle(
          Colors.blue.shade50,
          Colors.blue.shade700,
          Icons.send_rounded,
        );
      case ReferralStatus.pending:
        return _BadgeStyle(
          Colors.amber.shade50,
          Colors.amber.shade800,
          Icons.schedule_rounded,
        );
      case ReferralStatus.accepted:
      case ReferralStatus.confirmed:
        return _BadgeStyle(
          Colors.green.shade50,
          Colors.green.shade700,
          Icons.check_circle_rounded,
        );
      case ReferralStatus.rejected:
        return _BadgeStyle(
          Colors.red.shade50,
          Colors.red.shade700,
          Icons.cancel_rounded,
        );
    }
  }
}

class _BadgeStyle {
  const _BadgeStyle(this.background, this.foreground, this.icon);

  final Color background;
  final Color foreground;
  final IconData icon;
}
