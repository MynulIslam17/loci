import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/respond_meeting_controller.dart';
import 'package:loci/routes/app_routes.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';

enum _NotificationKind { meeting, referral, other }

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  _NotificationKind get _kind {
    final t = notification.type.toLowerCase();
    if (t.contains('meeting')) return _NotificationKind.meeting;
    if (t.contains('referral')) return _NotificationKind.referral;
    return _NotificationKind.other;
  }

  /// Best-effort lookup for the entity id the notification refers to.
  String? get _referenceId {
    for (final key in const [
      'meetingId',
      'referralId',
      'referenceId',
      'id',
      '_id',
    ]) {
      final value = notification.data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  bool get _canRespondToMeeting =>
      _kind == _NotificationKind.meeting &&
      notification.actionRequired &&
      _referenceId != null;

  void _onTapBody() {
    switch (_kind) {
      case _NotificationKind.meeting:
        // Land on the Received tab — this is an incoming invitation.
        Get.toNamed(AppRoutes.meeting, arguments: {'initialTab': 'received'});
        break;
      case _NotificationKind.referral:
        Get.toNamed(AppRoutes.referral);
        break;
      case _NotificationKind.other:
        break;
    }
  }

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
          onTap: _onTapBody,
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
                                  decoration: const BoxDecoration(
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
                if (_canRespondToMeeting) ...[
                  const SizedBox(height: 12),
                  _MeetingActionRow(meetingId: _referenceId!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirm / Reject buttons for a meeting notification.
/// Reads the live respond state from [RespondMeetingController] so the
/// button shows a spinner while the request is in flight.
class _MeetingActionRow extends StatelessWidget {
  final String meetingId;

  const _MeetingActionRow({required this.meetingId});

  RespondMeetingController _responder() {
    if (!Get.isRegistered<RespondMeetingController>()) {
      Get.put(
        RespondMeetingController(Get.find<NetworkService>()),
        permanent: true,
      );
    }
    return Get.find<RespondMeetingController>();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _responder();

    return Obx(() {
      final isConfirming = ctrl.isConfirming(meetingId);
      final isRejecting = ctrl.isRejecting(meetingId);
      final isBusy = ctrl.isResponding(meetingId);

      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isBusy
                  ? null
                  : () => ctrl.respond(
                      meetingId,
                      RespondMeetingController.confirmAction,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF62B4AC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isConfirming
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
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
              onPressed: isBusy
                  ? null
                  : () => ctrl.respond(
                      meetingId,
                      RespondMeetingController.rejectAction,
                    ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isRejecting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.redAccent,
                      ),
                    )
                  : Text(
                      "Reject",
                      style: AppTextStyle.textSm(
                        color: Colors.redAccent,
                        weight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class TypeIcon extends StatelessWidget {
  final String type;

  const TypeIcon({super.key, required this.type});

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
