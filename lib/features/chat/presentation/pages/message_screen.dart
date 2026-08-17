import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/chat/data/models/chat_message_model.dart';
import 'package:loci/features/chat/data/models/chat_user_model.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';
import 'package:loci/features/chat/presentation/controllers/chat_controller.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:loci/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:loci/features/chat/presentation/widgets/chat_message_shimmer.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/empty_state.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late final ChatController controller;
  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scroll = ScrollController();
  int _lastCount = 0;

  late final ChatUserModel _other;

  /// Registered app-wide; provides live presence for the header status.
  ChatListController? get _listCtrl => Get.isRegistered<ChatListController>()
      ? Get.find<ChatListController>()
      : null;

  @override
  void initState() {
    super.initState();
    final args = (Get.arguments as Map?) ?? {};
    _other = ChatUserModel(
      id: (args['otherId'] ?? '').toString(),
      name: (args['otherName'] ?? '').toString(),
      avatar: args['otherAvatar']?.toString(),
      lastSeen: args['otherLastSeen']?.toString(),
    );

    controller = Get.put(
      ChatController(
        Get.find<ChatService>(),
        conversationId: args['conversationId']?.toString(),
        recipientId: args['recipientId']?.toString(),
        other: _other,
      ),
    );

    _scroll.addListener(_onScroll);
  }

  /// In the reversed list, maxScrollExtent is the visual top (oldest side).
  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 200) {
      controller.loadOlderMessages();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    Get.delete<ChatController>();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    final editing = controller.editingMessage.value;
    if (editing != null) {
      if (text != (editing.content ?? '').trim()) {
        controller.editMessage(editing, text);
      }
      _cancelEdit();
      return;
    }

    controller.sendMessage(text);
    _input.clear();
    controller.onInputChanged('');
  }

  /// Loads the message into the input box, Messenger-style.
  void _startEdit(ChatMessageModel msg) {
    controller.editingMessage.value = msg;
    _input.text = msg.content ?? '';
    _input.selection = TextSelection.collapsed(offset: _input.text.length);
    _inputFocus.requestFocus();
  }

  void _cancelEdit() {
    controller.editingMessage.value = null;
    _input.clear();
    controller.onInputChanged('');
  }

  /// Facebook-style: "Active 20m ago" / "Active 3h ago" / "Active yesterday".
  /// Prefers the live lastSeen from `chat:user_offline` over the fetched one.
  String? _lastSeenText() {
    final iso = _listCtrl?.lastSeenFor(_other) ?? _other.lastSeen;
    if (iso == null) return null;
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return null;

    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Active just now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Active ${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Active yesterday';
    return 'Active ${DateFormat('MMM d').format(dt)}';
  }

  void _jumpToBottomIfNeeded(int count) {
    if (count == _lastCount) return;
    final grew = count > _lastCount;
    _lastCount = count;
    if (!grew) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Offset 0 is the newest message in the reversed list.
      if (_scroll.hasClients && _scroll.position.pixels < 300) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Obx(
              () => ChatAvatar(
                name: _other.name,
                avatarUrl: _other.avatar,
                size: 40,
                showOnlineDot: _listCtrl?.isUserActive(_other) ?? false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() {
                final typing = controller.otherIsTyping.value;
                final online = _listCtrl?.isUserActive(_other) ?? false;
                final status = typing
                    ? 'typing…'
                    : online
                    ? 'Active now'
                    : _lastSeenText();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _other.name.isEmpty ? 'Chat' : _other.name,
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    if (status != null)
                      Text(
                        status,
                        style: AppTextStyle.textXs(
                          color: typing
                              ? colorScheme.primary
                              : online
                              ? Colors.green
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Obx(() {
                final ctrl = controller;
                if (ctrl.isLoading.value && ctrl.messages.isEmpty) {
                  return const ChatMessageShimmer();
                }
                if (ctrl.messages.isEmpty) {
                  return AdaptiveRefresh(
                    onRefresh: ctrl.loadMessages,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: const EmptyState(
                              icon: Icons.chat_bubble_outline,
                              title: 'No messages yet',
                              subtitle: 'Say hello to start the conversation',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                _jumpToBottomIfNeeded(ctrl.messages.length);

              final count = ctrl.messages.length;
              final showTopLoader = ctrl.isLoadingMore.value;
              // Reverse list: index 0 is the bottom, where the typing
              // bubble sits while the other person is typing.
              final showTyping = ctrl.otherIsTyping.value;
              final typingOffset = showTyping ? 1 : 0;

              return ListView.builder(
                controller: _scroll,
                reverse: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: count + typingOffset + (showTopLoader ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showTyping && index == 0) {
                    return _TypingBubble(
                      otherName: _other.name,
                      otherAvatar: _other.avatar,
                    );
                  }
                  final msgIndex = index - typingOffset;
                  if (msgIndex >= count) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final msg = ctrl.messages[count - 1 - msgIndex];
                  final actionable =
                      !msg.isDeleted && msg.status != 'sending' && msg.status != 'failed';
                  return _MessageBubble(
                    message: msg,
                    isMe: ctrl.isMine(msg),
                    otherAvatar: _other.avatar,
                    otherName: _other.name,
                    myReaction: msg.myReaction(ctrl.myId),
                    onLongPress: () => _showMessageActions(msg),
                    onRetry: () => ctrl.retryMessage(msg),
                    onDoubleTap: actionable
                        ? () => ctrl.toggleReaction(msg, '❤️')
                        : null,
                    // Tap a chip: same emoji removes my reaction, a
                    // different one switches to it.
                    onToggleReaction: actionable
                        ? (emoji) => ctrl.toggleReaction(msg, emoji)
                        : null,
                  );
                },
              );
            }),
            ),
          ),
          _buildInput(context),
        ],
      ),
    );
  }

  static const List<String> _quickEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  void _showMessageActions(ChatMessageModel msg) {
    FocusManager.instance.primaryFocus?.unfocus();
    final colorScheme = context.colorScheme;
    final isMe = controller.isMine(msg);
    final deleted = msg.isDeleted;
    final sending = msg.status == 'sending';
    final failed = msg.status == 'failed';
    if (sending) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final myReaction = msg.myReaction(controller.myId);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              if (isMe && failed)
                ListTile(
                  leading: Icon(
                    Icons.refresh,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Retry sending'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.retryMessage(msg);
                  },
                ),
              if (!deleted && !failed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _quickEmojis.map((emoji) {
                    final selected = myReaction == emoji;
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        controller.toggleReaction(msg, emoji);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (!deleted && !failed) const SizedBox(height: 8),
              if (isMe && !deleted && !failed && msg.canEdit)
                ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.onSurface,
                  ),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _startEdit(msg);
                  },
                ),
              // Gated by the server's canUnsend flag + 15-min window; the
              // server re-checks anyway and the controller rolls back on
              // rejection.
              if (isMe && !deleted && msg.canUnsend)
                ListTile(
                  leading: Icon(
                    Icons.replay_outlined,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    'Unsend',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  subtitle: const Text('Removes the message for everyone'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.unsendMessage(msg);
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: const Text('Delete for me'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.deleteForMe(msg);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInput(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      // No divider above the composer — it blends into the thread like
      // Messenger; the filled rounded field provides its own definition.
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEditBanner(colorScheme),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    focusNode: _inputFocus,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    onChanged: (value) {
                      // Editing an old message isn't "typing" to the other side.
                      if (controller.editingMessage.value == null) {
                        controller.onInputChanged(value);
                      }
                    },
                    style: AppTextStyle.textSm(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Your message...",
                      hintStyle: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSendButton(colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// "Edit message" strip above the input while editing, like Messenger.
  Widget _buildEditBanner(ColorScheme colorScheme) {
    return Obx(() {
      final editing = controller.editingMessage.value;
      if (editing == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(Icons.edit_outlined, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit message',
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    editing.content ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close, size: 20, color: colorScheme.onSurface),
              onPressed: _cancelEdit,
            ),
          ],
        ),
      );
    });
  }

  /// Send (or confirm-edit) button. Disabled while empty, and in edit mode
  /// also while the text is unchanged from the original.
  Widget _buildSendButton(ColorScheme colorScheme) {
    return Obx(() {
      final editing = controller.editingMessage.value;
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: _input,
        builder: (context, value, _) {
          final text = value.text.trim();
          final enabled =
              text.isNotEmpty &&
              (editing == null || text != (editing.content ?? '').trim());
          return GestureDetector(
            onTap: enabled ? _send : null,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: enabled
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                editing != null ? Icons.check : Icons.send,
                color: enabled
                    ? Colors.white
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          );
        },
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final String? otherAvatar;
  final String otherName;
  final String? myReaction;
  final VoidCallback onLongPress;
  final VoidCallback? onRetry;
  final VoidCallback? onDoubleTap;
  final ValueChanged<String>? onToggleReaction;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.otherAvatar,
    required this.otherName,
    required this.myReaction,
    required this.onLongPress,
    this.onRetry,
    required this.onDoubleTap,
    required this.onToggleReaction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final deleted = message.isDeleted;
    final reply = message.replyTo;

    final hasReactions = !deleted && message.reactions.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            ChatAvatar(name: otherName, avatarUrl: otherAvatar, size: 30),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      // Room for the reaction chip overlapping the corner.
                      padding: EdgeInsets.only(bottom: hasReactions ? 10 : 0),
                      child: GestureDetector(
                        onTap: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        onLongPress: onLongPress,
                        onDoubleTap: onDoubleTap,
                        child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? (message.status == 'failed'
                              ? colorScheme.primary.withValues(alpha: 0.8)
                              : colorScheme.primary)
                          : colorScheme.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 2),
                        bottomRight: Radius.circular(isMe ? 2 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!deleted && reply != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (isMe ? Colors.white : colorScheme.primary)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(
                                  color: isMe
                                      ? Colors.white70
                                      : colorScheme.primary,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              // Null content on a non-deleted quote means I
                              // removed the original from my own history.
                              (reply.content ?? '').isNotEmpty
                                  ? reply.content!
                                  : 'Original message unavailable',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTextStyle.textXs(
                                    color: isMe
                                        ? Colors.white70
                                        : colorScheme.onSurfaceVariant,
                                  ).copyWith(
                                    fontStyle: (reply.content ?? '').isEmpty
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          // Messenger-style tombstone: the row stays visible.
                          deleted
                              ? (isMe
                                    ? 'You unsent a message'
                                    : '${otherName.isEmpty ? 'They' : otherName} unsent a message')
                              : (message.content ?? ''),
                          style:
                              AppTextStyle.textSm(
                                color: deleted
                                    ? (isMe
                                          ? Colors.white70
                                          : colorScheme.onSurfaceVariant)
                                    : (isMe
                                          ? Colors.white
                                          : colorScheme.onSurface),
                              ).copyWith(
                                fontStyle: deleted
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                        ),
                      ],
                    ),
                  ),
                      ),
                    ),
                    if (hasReactions)
                      Positioned(
                        bottom: -2,
                        right: isMe ? 4 : null,
                        left: isMe ? null : 4,
                        child: _ReactionChips(
                          message: message,
                          myReaction: myReaction,
                          onToggle: onToggleReaction,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                _MetaRow(
                  message: message,
                  isMe: isMe,
                  onRetry: onRetry,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionChips extends StatelessWidget {
  final ChatMessageModel message;
  final String? myReaction;

  /// Tapping a chip toggles my reaction: same emoji removes it, a different
  /// one switches to it (one reaction per user, server-enforced).
  final ValueChanged<String>? onToggle;

  const _ReactionChips({
    required this.message,
    required this.myReaction,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final counts = <String, int>{};
    for (final r in message.reactions) {
      counts[r.emoji] = (counts[r.emoji] ?? 0) + 1;
    }

    return Wrap(
      spacing: 4,
      children: counts.entries.map((entry) {
        final isMine = entry.key == myReaction;
        final chip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            // Surface-colored outline makes the chip read as floating over
            // the bubble corner, like Messenger/WhatsApp.
            border: Border.all(
              color: isMine ? colorScheme.primary : colorScheme.surface,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text.rich(
            TextSpan(
              children: [
                // No color on the emoji span: forcing a color makes ❤️ fall
                // back to the monochrome (black) text glyph.
                TextSpan(
                  text: entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
                if (entry.value > 1)
                  TextSpan(
                    text: ' ${entry.value}',
                    style: AppTextStyle.textXs(color: colorScheme.onSurface),
                  ),
              ],
            ),
          ),
        );
        if (onToggle == null) return chip;
        return GestureDetector(
          onTap: () => onToggle!(entry.key),
          child: chip,
        );
      }).toList(),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final VoidCallback? onRetry;
  const _MetaRow({
    required this.message,
    required this.isMe,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final time = _time(message.createdAt);
    final isFailed = message.status == 'failed';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited && !message.isDeleted) ...[
          Text(
            'edited',
            style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          time,
          style: AppTextStyle.textXs(
            color: isFailed ? colorScheme.error : colorScheme.onSurfaceVariant,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          if (isFailed && onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 13,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Retry',
                    style: AppTextStyle.textXs(
                      color: colorScheme.error,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            _statusIcon(colorScheme),
        ],
      ],
    );
  }

  /// WhatsApp read-receipt blue.
  static const Color _readBlue = Color(0xFF34B7F1);

  /// WhatsApp flow: clock while sending, ! failed, ✓ sent, ✓✓ delivered, blue ✓✓ read.
  Widget _statusIcon(ColorScheme colorScheme) {
    if (message.status == 'failed') {
      return Icon(
        Icons.error_outline,
        size: 14,
        color: colorScheme.error,
      );
    }
    if (message.status == 'sending') {
      return Icon(
        Icons.access_time,
        size: 12,
        color: colorScheme.onSurfaceVariant,
      );
    }
    if (message.status == 'read') {
      return const Icon(Icons.done_all, size: 14, color: _readBlue);
    }
    if (message.status == 'delivered') {
      return Icon(
        Icons.done_all,
        size: 14,
        color: colorScheme.onSurfaceVariant,
      );
    }
    return Icon(Icons.done, size: 14, color: colorScheme.onSurfaceVariant);
  }

  String _time(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    return DateFormat('h:mm a').format(dt);
  }
}

/// Messenger-style typing bubble: the other person's avatar next to a bubble
/// with three pulsing dots. Shown as the bottom row while `chat:typing`
/// reports `isTyping: true`; the server retracts it if their socket drops.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble({required this.otherName, required this.otherAvatar});

  final String otherName;
  final String? otherAvatar;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ChatAvatar(
            name: widget.otherName,
            avatarUrl: widget.otherAvatar,
            size: 30,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    // Stagger each dot a third of a cycle apart.
                    final phase = (_controller.value - i * 0.2) % 1.0;
                    final wave = math.sin(phase * math.pi * 2);
                    final lift = wave > 0 ? wave : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: i == 0 ? 0 : 4,
                        bottom: lift * 4,
                      ),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4 + lift * 0.6,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
