import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loci/core/enums/notification_type.dart';
import 'package:loci/features/push_notification/data/models/notification_payload.dart';

void main() {
  group('NotificationPayload.fromRemoteMessage', () {
    test('exposes the notification block through the data accessors', () {
      final payload = NotificationPayload.fromRemoteMessage(
        const RemoteMessage(
          messageId: 'fcm-1',
          notification: RemoteNotification(title: 'Alex', body: 'hey'),
          data: {'type': 'new_message', 'conversationId': 'c1'},
        ),
      );

      expect(payload.title, 'Alex');
      expect(payload.body, 'hey');
      expect(payload.type, NotificationType.newMessage);
    });

    test('a data-only payload carries its own title and body', () {
      final payload = NotificationPayload.fromRemoteMessage(
        const RemoteMessage(data: {'title': 'Alex', 'body': 'hey'}),
      );

      expect(payload.title, 'Alex');
      expect(payload.body, 'hey');
    });

    test('data values win over the notification block', () {
      final payload = NotificationPayload.fromRemoteMessage(
        const RemoteMessage(
          notification: RemoteNotification(title: 'generic'),
          data: {'title': 'specific'},
        ),
      );

      expect(payload.title, 'specific');
    });
  });

  group('de-duplication', () {
    test('prefers the application message id over the transport id', () {
      final payload = NotificationPayload.fromRemoteMessage(
        const RemoteMessage(messageId: 'fcm-1', data: {'messageId': 'm1'}),
      );

      expect(payload.dedupeId, 'm1');
    });

    test('falls back to the transport id when none is supplied', () {
      final payload = NotificationPayload.fromRemoteMessage(
        const RemoteMessage(messageId: 'fcm-1'),
      );

      expect(payload.dedupeId, 'fcm-1');
    });

    test('never dedupes on entityId, which repeats across notifications', () {
      const payload = NotificationPayload({'entityId': 'event-1'});

      expect(payload.dedupeId, isNull);
    });

    test('the socket and push paths agree on the same message', () {
      final fromSocket = NotificationPayload.chatMessage(
        conversationId: 'c1',
        messageId: 'm1',
        senderId: 's1',
        senderName: 'Alex',
        body: 'hey',
      );
      final fromPush = NotificationPayload.fromRemoteMessage(
        const RemoteMessage(
          messageId: 'fcm-1',
          data: {'conversationId': 'c1', 'messageId': 'm1'},
        ),
      );

      expect(fromSocket.dedupeId, fromPush.dedupeId);
    });
  });

  group('chat detection', () {
    test('a conversation id marks the payload as a chat message', () {
      const payload = NotificationPayload({'conversationId': 'c1'});

      expect(payload.isChatMessage, isTrue);
      expect(payload.conversationId, 'c1');
    });

    test('accepts the chatId alias', () {
      const payload = NotificationPayload({'chatId': 'c1'});

      expect(payload.conversationId, 'c1');
    });

    test('an entity notification is not mistaken for a chat', () {
      const payload = NotificationPayload({
        'type': 'raffle_completed',
        'entityId': 'raffle-1',
      });

      expect(payload.isChatMessage, isFalse);
      expect(payload.conversationId, isNull);
      expect(payload.entityId, 'raffle-1');
    });
  });

  group('chatMessage builder', () {
    test('round-trips every field the tap handler needs', () {
      final payload = NotificationPayload.chatMessage(
        conversationId: 'c1',
        messageId: 'm1',
        senderId: 's1',
        senderName: 'Alex',
        senderAvatar: 'https://example.com/a.jpg',
        body: 'hey',
      );

      // Survives the JSON encode/decode the tray notification puts it through.
      final restored = NotificationPayload(
        Map<String, dynamic>.from(payload.data),
      );

      expect(restored.type, NotificationType.newMessage);
      expect(restored.conversationId, 'c1');
      expect(restored.senderId, 's1');
      expect(restored.senderName, 'Alex');
      expect(restored.senderAvatar, 'https://example.com/a.jpg');
      expect(restored.title, 'Alex');
      expect(restored.body, 'hey');
    });

    test('omits a blank avatar rather than storing an empty string', () {
      final payload = NotificationPayload.chatMessage(
        conversationId: 'c1',
        messageId: 'm1',
        senderId: 's1',
        senderName: 'Alex',
        senderAvatar: '   ',
        body: 'hey',
      );

      expect(payload.data.containsKey('senderAvatar'), isFalse);
      expect(payload.senderAvatar, isNull);
    });
  });

  test('blank values read as absent', () {
    const payload = NotificationPayload({'title': '   ', 'senderName': ''});

    expect(payload.title, isNull);
    expect(payload.senderName, isNull);
  });
}
