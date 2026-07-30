import 'package:get/get.dart';
import 'package:loci/core/enums/notification_type.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';
import 'package:loci/routes/app_routes.dart';

/// Maps each [NotificationType] to the screen the user should open on tap.
class NotificationNavigation {
  NotificationNavigation._();

  static void open(NotificationModel notification) {
    if (notification.showsInlineActions) return;

    switch (notification.notificationType) {
      case NotificationType.referralReceived:
        Get.toNamed(
          AppRoutes.referral,
          arguments: const {'initialTab': 'received'},
        );
        break;
      case NotificationType.referralAccepted:
      case NotificationType.referralRejected:
        Get.toNamed(AppRoutes.referral);
        break;
      case NotificationType.meetingRequest:
        Get.toNamed(
          AppRoutes.meeting,
          arguments: const {'initialTab': 'received'},
        );
        break;
      case NotificationType.meetingConfirmed:
      case NotificationType.meetingRejected:
        Get.toNamed(AppRoutes.meeting);
        break;
      case NotificationType.newMessage:
        Get.toNamed(AppRoutes.chatList);
        break;
      case NotificationType.eventRsvp:
        final id = notification.entityId;
        if (id != null && id.isNotEmpty) {
          Get.toNamed(AppRoutes.eventDetails, arguments: {'eventId': id});
        }
        break;
      case NotificationType.raffleCompleted:
        final id = notification.entityId;
        if (id != null && id.isNotEmpty) {
          Get.toNamed(AppRoutes.rafflesDetails, arguments: {'raffleId': id});
        }
        break;
      case NotificationType.businessClaimSubmitted:
      case NotificationType.businessClaimApproved:
        Get.toNamed(AppRoutes.searchBusiness);
        break;
      case NotificationType.questionAnswered:
        Get.toNamed(AppRoutes.bottomNav);
        break;
      case NotificationType.communityMemberInvite:
      case NotificationType.unknown:
        break;
    }
  }
}
