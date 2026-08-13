import 'dart:async';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../constants/app_url.dart';
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
  /// Chat socket logs print in brown; errors stay red so failures pop out.
  static const AnsiColor _brown = AnsiColor.fg(130);
  static const AnsiColor _red = AnsiColor.fg(196);

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      levelColors: {
        Level.trace: _brown,
        Level.debug: _brown,
        Level.info: _brown,
        Level.warning: _brown,
        Level.error: _red,
        Level.fatal: _red,
      },
    ),
  );

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  // ── Broadcast streams controllers listen to ────────────────────────────────
  final _messageCtrl = StreamController<ChatMessageModel>.broadcast();
  final _ackCtrl = StreamController<MessageAck>.broadcast();
  final _editedCtrl = StreamController<ChatMessageModel>.broadcast();
  final _deletedCtrl = StreamController<MessageDeleted>.broadcast();
  final _readCtrl = StreamController<MessagesRead>.broadcast();
  final _deliveredCtrl = StreamController<MessageDelivered>.broadcast();
  final _reactionCtrl = StreamController<ReactionUpdate>.broadcast();
  final _typingCtrl = StreamController<TypingEvent>.broadcast();
  final _presenceCtrl = StreamController<PresenceEvent>.broadcast();
  final _errorCtrl = StreamController<String>.broadcast();
  final _connectionCtrl = StreamController<bool>.broadcast();

  Stream<ChatMessageModel> get onMessage => _messageCtrl.stream;

  /// true on every (re)connect, false on disconnect. Room membership does not
  /// survive a reconnect, so open threads must re-join and refetch their tail.
  Stream<bool> get onConnectionChanged => _connectionCtrl.stream;
  Stream<MessageAck> get onAck => _ackCtrl.stream;
  Stream<ChatMessageModel> get onEdited => _editedCtrl.stream;
  Stream<MessageDeleted> get onDeleted => _deletedCtrl.stream;
  Stream<MessagesRead> get onRead => _readCtrl.stream;
  Stream<MessageDelivered> get onDelivered => _deliveredCtrl.stream;
  Stream<ReactionUpdate> get onReaction => _reactionCtrl.stream;
  Stream<TypingEvent> get onTyping => _typingCtrl.stream;
  Stream<PresenceEvent> get onPresence => _presenceCtrl.stream;
  Stream<String> get onError => _errorCtrl.stream;

  /// Token the current socket was built with — rebuild only when it changes,
  /// so repeated connect() calls don't spawn parallel managers (which keep
  /// retrying after dispose and double every log/event).
  String? _socketToken;

  // ── Connection lifecycle ────────────────────────────────────────────────────
  void connect() {
    final token = Get.find<AuthController>().accessToken ?? '';
    if (token.isEmpty) {
      _logger.w('ChatSocket: no token, skipping connect.');
      return;
    }

    if (_socket != null && _socketToken == token) {
      if (_socket!.connected) {
        _logger.d('ChatSocket: connect() called but already connected.');
      } else {
        // Manager is already retrying with this token; don't stack another.
        _logger.d('ChatSocket: connect already in progress, ignoring.');
      }
      return;
    }

    _socket?.dispose();
    _socket = null;

    _logger.d('ChatSocket: connecting to ${AppUrl.socketUrl} …');

    _socket = io.io(
      AppUrl.socketUrl,
      io.OptionBuilder()
          // WebSocket only: socket_io_client's polling transport needs
          // browser XHR and does not work on native Flutter — listing it
          // first made every connect attempt hang until timeout.
          .setTransports(['websocket'])
          .disableAutoConnect()
          // New Manager per session — never reuse a cached (possibly
          // disposed) engine or a stale auth token.
          .disableMultiplex()
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );
    _socketToken = token;

    _registerListeners();
    _socket!.connect();
  }

  void disconnect() {
    _logger.d('ChatSocket: disconnect() — disposing socket.');
    _socket?.dispose();
    _socket = null;
    _socketToken = null;
  }

  /// Registers [handler] for [event], logging every payload that arrives.
  void _onEvent(String event, void Function(dynamic data) handler) {
    _socket!.on(event, (data) {
      _logger.d('ChatSocket ⇐ $event\n$data');
      handler(data);
    });
  }

  void _registerListeners() {
    final s = _socket!;
    s.onConnect((_) {
      _logger.i('ChatSocket ✔ connected (id: ${s.id})');
      _connectionCtrl.add(true);
    });
    s.onDisconnect((reason) {
      _logger.w('ChatSocket ✖ disconnected: $reason');
      _connectionCtrl.add(false);
    });
    s.onConnectError((e) => _logger.e('ChatSocket ✖ connect error: $e'));
    s.onError((e) => _logger.e('ChatSocket ✖ socket error: $e'));
    s.onReconnectAttempt(
      (attempt) => _logger.d('ChatSocket ↻ reconnect attempt $attempt'),
    );
    s.onReconnect((_) => _logger.i('ChatSocket ↻ reconnected'));

    _onEvent(ChatSocketEvent.messageReceived, (data) {
      final msg = _extractMessage(data);
      if (msg != null) _messageCtrl.add(msg);
    });

    _onEvent(ChatSocketEvent.messageSentAck, (data) {
      final map = _asMap(data);
      final msg = _extractMessage(data);
      if (msg != null) {
        _ackCtrl.add(MessageAck(tempId: map['tempId']?.toString(), message: msg));
      }
    });

    _onEvent(ChatSocketEvent.messageEdited, (data) {
      final msg = _extractMessage(data);
      if (msg != null) _editedCtrl.add(msg);
    });

    _onEvent(ChatSocketEvent.messageDeleted, (data) {
      final map = _asMap(data);
      _deletedCtrl.add(MessageDeleted(
        messageId: map['messageId']?.toString() ?? '',
        conversationId: map['conversationId']?.toString() ?? '',
        forEveryone: map['forEveryone'] == true,
      ));
    });

    _onEvent(ChatSocketEvent.messagesRead, (data) {
      final map = _asMap(data);
      _readCtrl.add(MessagesRead(
        conversationId: map['conversationId']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
      ));
    });

    _onEvent(ChatSocketEvent.messageDelivered, (data) {
      final map = _asMap(data);
      _deliveredCtrl.add(MessageDelivered(
        conversationId: map['conversationId']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
      ));
    });

    _onEvent(ChatSocketEvent.messageReactionUpdated, (data) {
      final map = _asMap(data);
      final raw = map['reactions'];
      _reactionCtrl.add(ReactionUpdate(
        messageId: map['messageId']?.toString() ?? '',
        reactions: raw is List
            ? raw
                .whereType<Map>()
                .map((e) =>
                    ChatReaction.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : const [],
      ));
    });

    _onEvent(ChatSocketEvent.typing, (data) {
      final map = _asMap(data);
      _typingCtrl.add(TypingEvent(
        conversationId: map['conversationId']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        isTyping: map['isTyping'] == true,
      ));
    });

    _onEvent(ChatSocketEvent.userOnline, (data) {
      final map = _asMap(data);
      _presenceCtrl.add(PresenceEvent(userId: map['userId']?.toString() ?? '', isOnline: true));
    });
    _onEvent(ChatSocketEvent.userOffline, (data) {
      final map = _asMap(data);
      _presenceCtrl.add(PresenceEvent(
        userId: map['userId']?.toString() ?? '',
        isOnline: false,
        lastSeen: map['lastSeen']?.toString(),
      ));
    });

    _onEvent(ChatSocketEvent.error, (data) {
      final map = _asMap(data);
      _errorCtrl.add(map['message']?.toString() ?? 'Chat error');
    });
  }

  // ── Emitters ─────────────────────────────────────────────────────────────────

  /// Emits [event] with [payload], logging it. Warns when the socket isn't
  /// connected so silently-dropped emits are visible in the log.
  void _emit(String event, dynamic payload) {
    if (_socket == null) {
      _logger.w('ChatSocket ⇏ $event dropped — socket not created.\n$payload');
      return;
    }
    if (!_socket!.connected) {
      _logger.w('ChatSocket ⇢ $event queued — not connected yet.\n$payload');
    } else {
      _logger.d('ChatSocket ⇒ $event\n$payload');
    }
    _socket!.emit(event, payload);
  }

  void joinConversation(String conversationId) =>
      _emit(ChatSocketEvent.joinConversation, conversationId);

  void leaveConversation(String conversationId) =>
      _emit(ChatSocketEvent.leaveConversation, conversationId);

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
    _emit(ChatSocketEvent.sendMessage, {
      'conversationId': ?conversationId,
      'recipientId': ?recipientId,
      'content': content,
      'replyTo': ?replyTo,
      'tempId': ?tempId,
    });
  }

  void markRead(String conversationId) =>
      _emit(ChatSocketEvent.markRead, {'conversationId': conversationId});

  void startTyping(String conversationId) => _emit(
      ChatSocketEvent.typingStart, {'conversationId': conversationId, 'isTyping': true});

  void stopTyping(String conversationId) => _emit(
      ChatSocketEvent.typingStop, {'conversationId': conversationId, 'isTyping': false});

  void editMessage(String messageId, String content) =>
      _emit(ChatSocketEvent.editMessage, {'messageId': messageId, 'content': content});

  void deleteMessage(String messageId, {required bool forEveryone}) => _emit(
      ChatSocketEvent.deleteMessage, {'messageId': messageId, 'forEveryone': forEveryone});

  void react(String messageId, String emoji) =>
      _emit(ChatSocketEvent.reactMessage, {'messageId': messageId, 'emoji': emoji});

  void unreact(String messageId) =>
      _emit(ChatSocketEvent.unreactMessage, {'messageId': messageId});

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
    _deliveredCtrl.close();
    _reactionCtrl.close();
    _typingCtrl.close();
    _presenceCtrl.close();
    _errorCtrl.close();
    _connectionCtrl.close();
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

/// Emitted when [userId] joins the room: the sender's pending `sent`
/// messages in [conversationId] became `delivered`.
class MessageDelivered {
  final String conversationId;
  final String userId;
  MessageDelivered({required this.conversationId, required this.userId});
}

/// Full authoritative reaction list for a message after react/unreact.
class ReactionUpdate {
  final String messageId;
  final List<ChatReaction> reactions;
  ReactionUpdate({required this.messageId, required this.reactions});
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

  /// Only present on `chat:user_offline`.
  final String? lastSeen;
  PresenceEvent({required this.userId, required this.isOnline, this.lastSeen});
}
