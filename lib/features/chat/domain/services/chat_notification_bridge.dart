import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart' show AppLifecycleState, WidgetsBinding;
import 'package:get/get.dart';
import 'package:loci/core/services/notification/local_notification_service.dart';
import 'package:loci/core/services/notification/notification_payload.dart';
import 'package:loci/core/services/socket/chat_socket_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/notification/presentation/utils/notification_navigation.dart';

/// Notifies about chat messages that arrive over the socket instead of as a
/// push.
///
/// The backend suppresses push for a recipient whose socket is connected, so a
/// foregrounded app receives the message over the socket and no push at all —
/// [PushNotificationService]'s foreground handler never fires and the user sees
/// nothing. Posting from the socket event is also simply what a messaging app
/// does when it already holds the message.
///
/// This lives in the chat feature rather than beside the push service so that
/// chat models and preview wording stay out of `core`.
class ChatNotificationBridge extends GetxService {
  StreamSubscription<ChatMessageModel>? _sub;

  @override
  void onInit() {
    super.onInit();
    // iOS is excluded for the same reason LocalNotificationService is: APNs
    // renders alerts natively there, and a local copy would double up.
    if (!Platform.isAndroid) return;
    _sub = Get.find<ChatSocketService>().onMessage.listen(_onMessage);
  }

  void _onMessage(ChatMessageModel message) {
    if (!_isForeground || _isMine(message) || message.sender.id.isEmpty) return;

    final payload = NotificationPayload.chatMessage(
      conversationId: message.conversationId,
      messageId: message.id,
      senderId: message.sender.id,
      senderName: message.sender.name.isEmpty
          ? 'New message'
          : message.sender.name,
      senderAvatar: message.sender.avatar,
      body: _preview(message),
    );

    // The thread on screen renders the message itself.
    if (NotificationNavigation.isConversationOnScreen(payload)) return;

    LocalNotificationService.show(payload);
  }

  /// The socket can outlive a backgrounding, and FCM delivers in that window
  /// too. Let the push own it there so the two paths don't both post. A null
  /// state means no lifecycle event has arrived yet, i.e. early startup.
  bool get _isForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  /// Messages this user sent from another device echo back over the socket.
  bool _isMine(ChatMessageModel message) {
    final myId = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>().userModel?.id
        : null;
    return myId != null && message.sender.id == myId;
  }

  static String _preview(ChatMessageModel message) {
    final content = message.content?.trim();
    if (content != null && content.isNotEmpty) return content;
    final count = message.attachments.length;
    if (count > 0) return count == 1 ? 'Attachment' : '$count attachments';
    return 'New message';
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
