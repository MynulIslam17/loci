import 'dart:async';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/app_url.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';

/// Socket.io event names — must mirror the backend `ChatEvent` enum
/// (`src/sockets/chat.events.ts`).
abstract class ChatSocketEvent {
  static const userOnline = 'chat:user_online';
  static const userOffline = 'chat:user_offline';

  static const joinConversation = 'chat:join_conversation';
  static const leaveConversation = 'chat:leave_conversation';

  static const sendMessage = 'chat:send_message';
  static const messageReceived = 'chat:message_received';
  static const messageSentAck = 'chat:message_sent_ack';

  static const editMessage = 'chat:edit_message';
  static const messageEdited = 'chat:message_edited';
  static const deleteMessage = 'chat:delete_message';
  static const messageDeleted = 'chat:message_deleted';

  static const reactMessage = 'chat:react_message';
  static const unreactMessage = 'chat:unreact_message';
  static const messageReactionUpdated = 'chat:message_reaction_updated';

  static const markRead = 'chat:mark_read';
  static const messagesRead = 'chat:messages_read';
  static const messageDelivered = 'chat:message_delivered';

  static const typingStart = 'chat:typing_start';
  static const typingStop = 'chat:typing_stop';
  static const typing = 'chat:typing';

  static const error = 'chat:error';
}

/// Manages the single realtime Socket.io connection for chat.
///
/// Connects with the user's JWT (same token as REST) and re-broadcasts the
/// server's events through typed broadcast streams that controllers subscribe
/// to. One socket is shared app-wide (registered permanent in bindings).
class ChatSocketService extends GetxService {
  final Logger _logger = Logger();
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  // ── Broadcast streams controllers listen to ────────────────────────────────
  final _messageCtrl = StreamController<ChatMessageModel>.broadcast();
  final _ackCtrl = StreamController<MessageAck>.broadcast();
  final _editedCtrl = StreamController<ChatMessageModel>.broadcast();
  final _deletedCtrl = StreamController<MessageDeleted>.broadcast();
  final _readCtrl = StreamController<MessagesRead>.broadcast();
  final _typingCtrl = StreamController<TypingEvent>.broadcast();
  final _presenceCtrl = StreamController<PresenceEvent>.broadcast();
  final _errorCtrl = StreamController<String>.broadcast();

  Stream<ChatMessageModel> get onMessage => _messageCtrl.stream;
  Stream<MessageAck> get onAck => _ackCtrl.stream;
  Stream<ChatMessageModel> get onEdited => _editedCtrl.stream;
  Stream<MessageDeleted> get onDeleted => _deletedCtrl.stream;
  Stream<MessagesRead> get onRead => _readCtrl.stream;
  Stream<TypingEvent> get onTyping => _typingCtrl.stream;
  Stream<PresenceEvent> get onPresence => _presenceCtrl.stream;
  Stream<String> get onError => _errorCtrl.stream;

  // ── Connection lifecycle ────────────────────────────────────────────────────
  void connect() {
    final token = Get.find<AuthController>().accessToken ?? '';
    if (token.isEmpty) {
      _logger.w('ChatSocket: no token, skipping connect.');
      return;
    }
    if (_socket != null) {
      if (!_socket!.connected) _socket!.connect();
      return;
    }

    _socket = io.io(
      AppUrl.socketUrl,
      io.OptionBuilder()
          // Allow HTTP polling with upgrade to WebSocket. Polling works over any
          // transport (incl. `adb reverse` tunnels and proxies that block WS
          // upgrades); the client transparently upgrades to WebSocket when it can.
          .setTransports(['polling', 'websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    _registerListeners();
    _socket!.connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void _registerListeners() {
    final s = _socket!;
    s.onConnect((_) => _logger.i('ChatSocket connected'));
    s.onDisconnect((_) => _logger.w('ChatSocket disconnected'));
    s.onConnectError((e) => _logger.e('ChatSocket connect error: $e'));

    s.on(ChatSocketEvent.messageReceived, (data) {
      final msg = _extractMessage(data);
      if (msg != null) _messageCtrl.add(msg);
    });

    s.on(ChatSocketEvent.messageSentAck, (data) {
      final map = _asMap(data);
      final msg = _extractMessage(data);
      if (msg != null) {
        _ackCtrl.add(MessageAck(tempId: map['tempId']?.toString(), message: msg));
      }
    });

    s.on(ChatSocketEvent.messageEdited, (data) {
      final msg = _extractMessage(data);
      if (msg != null) _editedCtrl.add(msg);
    });

    s.on(ChatSocketEvent.messageDeleted, (data) {
      final map = _asMap(data);
      _deletedCtrl.add(MessageDeleted(
        messageId: map['messageId']?.toString() ?? '',
        conversationId: map['conversationId']?.toString() ?? '',
        forEveryone: map['forEveryone'] == true,
      ));
    });

    s.on(ChatSocketEvent.messagesRead, (data) {
      final map = _asMap(data);
      _readCtrl.add(MessagesRead(
        conversationId: map['conversationId']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
      ));
    });

    s.on(ChatSocketEvent.typing, (data) {
      final map = _asMap(data);
      _typingCtrl.add(TypingEvent(
        conversationId: map['conversationId']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        isTyping: map['isTyping'] == true,
      ));
    });

    s.on(ChatSocketEvent.userOnline, (data) {
      final map = _asMap(data);
      _presenceCtrl.add(PresenceEvent(userId: map['userId']?.toString() ?? '', isOnline: true));
    });
    s.on(ChatSocketEvent.userOffline, (data) {
      final map = _asMap(data);
      _presenceCtrl.add(PresenceEvent(userId: map['userId']?.toString() ?? '', isOnline: false));
    });

    s.on(ChatSocketEvent.error, (data) {
      final map = _asMap(data);
      _errorCtrl.add(map['message']?.toString() ?? 'Chat error');
    });
  }

  // ── Emitters ─────────────────────────────────────────────────────────────────
  void joinConversation(String conversationId) =>
      _socket?.emit(ChatSocketEvent.joinConversation, conversationId);

  void leaveConversation(String conversationId) =>
      _socket?.emit(ChatSocketEvent.leaveConversation, conversationId);

  /// Send a text message. Pass [conversationId] for an existing chat, or
  /// [recipientId] to start a new one. [tempId] correlates the optimistic
  /// bubble with the server ack.
  void sendMessage({
    String? conversationId,
    String? recipientId,
    required String content,
    String? replyTo,
    String? tempId,
  }) {
    _socket?.emit(ChatSocketEvent.sendMessage, {
      if (conversationId != null) 'conversationId': conversationId,
      if (recipientId != null) 'recipientId': recipientId,
      'content': content,
      if (replyTo != null) 'replyTo': replyTo,
      if (tempId != null) 'tempId': tempId,
    });
  }

  void markRead(String conversationId) =>
      _socket?.emit(ChatSocketEvent.markRead, {'conversationId': conversationId});

  void startTyping(String conversationId) => _socket?.emit(
      ChatSocketEvent.typingStart, {'conversationId': conversationId, 'isTyping': true});

  void stopTyping(String conversationId) => _socket?.emit(
      ChatSocketEvent.typingStop, {'conversationId': conversationId, 'isTyping': false});

  void editMessage(String messageId, String content) =>
      _socket?.emit(ChatSocketEvent.editMessage, {'messageId': messageId, 'content': content});

  void deleteMessage(String messageId, {required bool forEveryone}) => _socket
      ?.emit(ChatSocketEvent.deleteMessage, {'messageId': messageId, 'forEveryone': forEveryone});

  void react(String messageId, String emoji) =>
      _socket?.emit(ChatSocketEvent.reactMessage, {'messageId': messageId, 'emoji': emoji});

  // ── Parsing helpers ──────────────────────────────────────────────────────────
  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};

  ChatMessageModel? _extractMessage(dynamic data) {
    final map = _asMap(data);
    final raw = map['message'];
    if (raw is Map) return ChatMessageModel.fromJson(Map<String, dynamic>.from(raw));
    return null;
  }

  @override
  void onClose() {
    disconnect();
    _messageCtrl.close();
    _ackCtrl.close();
    _editedCtrl.close();
    _deletedCtrl.close();
    _readCtrl.close();
    _typingCtrl.close();
    _presenceCtrl.close();
    _errorCtrl.close();
    super.onClose();
  }
}

// ── Event payload value-objects ─────────────────────────────────────────────────
class MessageAck {
  final String? tempId;
  final ChatMessageModel message;
  MessageAck({required this.tempId, required this.message});
}

class MessageDeleted {
  final String messageId;
  final String conversationId;
  final bool forEveryone;
  MessageDeleted({
    required this.messageId,
    required this.conversationId,
    required this.forEveryone,
  });
}

class MessagesRead {
  final String conversationId;
  final String userId;
  MessagesRead({required this.conversationId, required this.userId});
}

class TypingEvent {
  final String conversationId;
  final String userId;
  final bool isTyping;
  TypingEvent({required this.conversationId, required this.userId, required this.isTyping});
}

class PresenceEvent {
  final String userId;
  final bool isOnline;
  PresenceEvent({required this.userId, required this.isOnline});
}
