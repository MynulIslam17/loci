import 'package:get/get.dart';
import 'package:loci/core/enums/notification_type.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/data/models/chat_user_model.dart';
import 'package:loci/features/chat/presentation/controllers/chat_controller.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';
import 'package:loci/features/push_notification/data/models/notification_payload.dart';
import 'package:loci/routes/app_routes.dart';

/// Maps each [NotificationType] to the screen the user should open on tap.
class NotificationNavigation {
  NotificationNavigation._();

  /// Entry point for a tapped notification that the app posted or received as
  /// a push. Anything we cannot route confidently falls back to the
  /// notifications list rather than leaving the tap dead.
  static void openFromPayload(NotificationPayload payload) {
    final data = payload.data;
    final notification = NotificationModel(
      id: (data['notificationId'] ?? data['_id'] ?? data['id'] ?? '').toString(),
      recipient: (data['recipient'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      title: payload.title ?? '',
      body: payload.body ?? '',
      data: data,
      actionRequired: data['actionRequired']?.toString() == 'true',
      isRead: false,
      createdAt: (data['createdAt'] ?? '').toString(),
    );

    if (_routesToDetail(notification)) {
      open(notification);
    } else {
      Get.toNamed(AppRoutes.notification);
    }
  }

  /// Whether [open] will actually navigate for this notification.
  static bool _routesToDetail(NotificationModel notification) {
    if (notification.showsInlineActions) return false;
    if (!notification.notificationType.opensDetailScreen) return false;

    // These two branches are no-ops without an entity to open.
    switch (notification.notificationType) {
      case NotificationType.eventRsvp:
      case NotificationType.raffleCompleted:
        return notification.entityId != null;
      default:
        return true;
    }
  }

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
        openConversation(NotificationPayload(notification.data));
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

  // ── Chat deep link ──────────────────────────────────────────────────────────

  /// Covers the pop transition plus the outgoing screen's `dispose`.
  static const _disposeGrace = Duration(milliseconds: 400);

  /// Whether [payload] targets the conversation the user is already looking at.
  /// That thread renders its own incoming messages over the socket, so a
  /// notification for it would be redundant — any other thread still needs one.
  static bool isConversationOnScreen(NotificationPayload payload) {
    if (Get.currentRoute != AppRoutes.message) return false;
    final conversationId = payload.conversationId;
    return conversationId != null && conversationId == _openConversationId;
  }

  /// Opens the conversation itself for a chat notification, rather than just
  /// the chat list. Falls back to the chat list when no conversation can be
  /// identified.
  static Future<void> openConversation(NotificationPayload payload) async {
    // The type is already known to be a chat message here, so the generic
    // `entityId` can safely be read as the conversation.
    final conversationId = payload.conversationId ?? payload.entityId;
    if (conversationId == null) {
      Get.toNamed(AppRoutes.chatList);
      return;
    }

    // MessageScreen puts one shared ChatController and deletes it on dispose,
    // so two of them must never sit on the stack — the outgoing screen's
    // dispose would tear down the incoming screen's controller. Pop first and
    // let the teardown finish before pushing the next conversation.
    if (Get.currentRoute == AppRoutes.message) {
      if (_openConversationId == conversationId) return;
      Get.back();
      await Future.delayed(_disposeGrace);
    }

    final chatList = _chatList;
    final other = _cachedCounterpart(conversationId, chatList);
    chatList?.clearUnread(conversationId);

    // One push, matching exactly what tapping a row in the chat list does.
    // This used to push the chat list first so Back would land there, but two
    // pushes issued in the same turn raced: the conversation mounted, joined
    // the room, and was torn straight back down, leaving the user on the list.
    // Landing Back wherever they were is a fair price for arriving at all.
    Get.toNamed(
      AppRoutes.message,
      arguments: {
        'conversationId': conversationId,
        'otherId': _nonEmpty(other?.id) ?? payload.senderId,
        'otherName': _nonEmpty(other?.name) ?? payload.senderName,
        'otherAvatar': _nonEmpty(other?.avatar) ?? payload.senderAvatar,
        'otherLastSeen': _nonEmpty(other?.lastSeen),
      },
    );
  }

  /// The cached conversation list knows the counterpart's avatar and last-seen,
  /// which a push payload generally does not carry.
  static ChatUserModel? _cachedCounterpart(
    String conversationId,
    ChatListController? chatList,
  ) {
    if (chatList == null) return null;
    final myId = _myId;
    for (final conversation in chatList.conversations) {
      if (conversation.id == conversationId) return conversation.other(myId);
    }
    return null;
  }

  static ChatListController? get _chatList =>
      Get.isRegistered<ChatListController>()
      ? Get.find<ChatListController>()
      : null;

  /// The conversation currently on screen, if MessageScreen is mounted.
  static String? get _openConversationId => Get.isRegistered<ChatController>()
      ? Get.find<ChatController>().conversationId
      : null;

  static String get _myId => Get.isRegistered<AuthController>()
      ? (Get.find<AuthController>().userModel?.id ?? '')
      : '';

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
