import 'package:flutter_test/flutter_test.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel.fromJson', () {
    test('parses full payload including windows, reactions and reply', () {
      final future = DateTime.now().toUtc().add(const Duration(hours: 1));
      final msg = ChatMessageModel.fromJson({
        '_id': 'm1',
        'conversationId': 'c1',
        'sender': {'_id': 'u1', 'name': 'Alice'},
        'content': 'hello',
        'status': 'delivered',
        'isEdited': true,
        'editedAt': '2026-08-08T04:00:00.000Z',
        'unsendableUntil': future.toIso8601String(),
        'editableUntil': future.toIso8601String(),
        'reactions': [
          {'user': 'u1', 'emoji': '👍'},
          {'user': 'u2', 'emoji': '❤️'},
        ],
        'replyTo': {'_id': 'm0', 'content': 'earlier message'},
      });

      expect(msg.id, 'm1');
      expect(msg.conversationId, 'c1');
      expect(msg.sender.id, 'u1');
      expect(msg.status, 'delivered');
      expect(msg.isEdited, isTrue);
      expect(msg.canEdit, isTrue);
      expect(msg.canUnsend, isTrue);
      expect(msg.reactions, hasLength(2));
      expect(msg.myReaction('u2'), '❤️');
      expect(msg.myReaction('u3'), isNull);
      expect(msg.replyTo?.id, 'm0');
      expect(msg.replyTo?.content, 'earlier message');
    });

    test('expired or missing windows disallow edit and unsend', () {
      final past = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      final expired = ChatMessageModel.fromJson({
        '_id': 'm2',
        'conversationId': 'c1',
        'sender': {'_id': 'u1', 'name': 'Alice'},
        'content': 'old',
        'unsendableUntil': past.toIso8601String(),
        'editableUntil': past.toIso8601String(),
      });
      expect(expired.canEdit, isFalse);
      expect(expired.canUnsend, isFalse);

      final missing = ChatMessageModel.fromJson({
        '_id': 'm3',
        'conversationId': 'c1',
        'sender': {'_id': 'u1', 'name': 'Alice'},
        'content': 'no windows',
      });
      expect(missing.canEdit, isFalse);
      expect(missing.canUnsend, isFalse);
    });

    test('server canUnsend/canEdit flags gate actions even inside the window',
        () {
      final future = DateTime.now().toUtc().add(const Duration(minutes: 5));
      final gated = ChatMessageModel.fromJson({
        '_id': 'm4',
        'conversationId': 'c1',
        'sender': {'_id': 'u1', 'name': 'Alice'},
        'content': 'hey',
        'canUnsend': false,
        'canEdit': false,
        'unsendableUntil': future.toIso8601String(),
        'editableUntil': future.toIso8601String(),
      });
      expect(gated.canUnsend, isFalse);
      expect(gated.canEdit, isFalse);

      final allowed = ChatMessageModel.fromJson({
        '_id': 'm5',
        'conversationId': 'c1',
        'sender': {'_id': 'u1', 'name': 'Alice'},
        'content': 'hey',
        'canUnsend': true,
        'canEdit': true,
        'unsendableUntil': future.toIso8601String(),
        'editableUntil': future.toIso8601String(),
      });
      expect(allowed.canUnsend, isTrue);
      expect(allowed.canEdit, isTrue);
    });
  });

  group('ChatMessageModel.copyWith', () {
    final base = ChatMessageModel.fromJson({
      '_id': 'm1',
      'conversationId': 'c1',
      'sender': {'_id': 'u1', 'name': 'Alice'},
      'content': 'hello',
      'status': 'sent',
    });

    test('flips status without touching content', () {
      final read = base.copyWith(status: 'read');
      expect(read.status, 'read');
      expect(read.content, 'hello');
      expect(read.id, 'm1');
    });

    test('tombstones a message via clearContent', () {
      final deleted = base.copyWith(isDeleted: true, clearContent: true);
      expect(deleted.isDeleted, isTrue);
      expect(deleted.content, isNull);
    });

    test('applies an edit', () {
      final edited = base.copyWith(content: 'hello world', isEdited: true);
      expect(edited.content, 'hello world');
      expect(edited.isEdited, isTrue);
    });

    test('replaces reactions', () {
      final reacted = base.copyWith(
        reactions: [ChatReaction(userId: 'u2', emoji: '😂')],
      );
      expect(reacted.reactions, hasLength(1));
      expect(reacted.myReaction('u2'), '😂');
    });
  });
}
