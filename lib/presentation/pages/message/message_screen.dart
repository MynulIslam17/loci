import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/chat/chat_message_model.dart';
import 'package:loci/data/models/chat/chat_user_model.dart';
import 'package:loci/presentation/controllers/chat/chat_controller.dart';
import 'package:loci/presentation/pages/message/widgets/chat_avatar.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late final ChatController controller;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastCount = 0;

  late final ChatUserModel _other;

  @override
  void initState() {
    super.initState();
    final args = (Get.arguments as Map?) ?? {};
    _other = ChatUserModel(
      id: (args['otherId'] ?? '').toString(),
      name: (args['otherName'] ?? '').toString(),
      avatar: args['otherAvatar']?.toString(),
    );

    controller = Get.put(
      ChatController(
        conversationId: args['conversationId']?.toString(),
        recipientId: args['recipientId']?.toString(),
        other: _other,
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    Get.delete<ChatController>();
    super.dispose();
  }

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    controller.sendMessage(text);
    _input.clear();
    controller.onInputChanged('');
  }

  void _jumpToBottomIfNeeded(int count) {
    if (count == _lastCount) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
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
            ChatAvatar(name: _other.name, avatarUrl: _other.avatar, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: GetBuilder<ChatController>(
                builder: (ctrl) => Column(
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
                    if (ctrl.otherIsTyping)
                      Text(
                        'typing…',
                        style: AppTextStyle.textXs(color: colorScheme.primary),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<ChatController>(
              builder: (ctrl) {
                if (ctrl.isLoading && ctrl.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.errorMessage != null && ctrl.messages.isEmpty) {
                  return Center(
                    child: Text(
                      ctrl.errorMessage!,
                      style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                if (ctrl.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hello 👋',
                      style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }

                _jumpToBottomIfNeeded(ctrl.messages.length);

                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: ctrl.messages.length,
                  itemBuilder: (context, index) {
                    final msg = ctrl.messages[index];
                    return _MessageBubble(
                      message: msg,
                      isMe: ctrl.isMine(msg),
                      otherAvatar: _other.avatar,
                      otherName: _other.name,
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                onChanged: controller.onInputChanged,
                style: AppTextStyle.textSm(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Your message...",
                  hintStyle: AppTextStyle.textSm(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final String? otherAvatar;
  final String otherName;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.otherAvatar,
    required this.otherName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final deleted = message.isDeleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            ChatAvatar(name: otherName, avatarUrl: otherAvatar, size: 30),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 2),
                      bottomRight: Radius.circular(isMe ? 2 : 16),
                    ),
                  ),
                  child: Text(
                    deleted ? 'This message was deleted' : (message.content ?? ''),
                    style: AppTextStyle.textSm(
                      color: deleted
                          ? (isMe ? Colors.white70 : colorScheme.onSurfaceVariant)
                          : (isMe ? Colors.white : colorScheme.onSurface),
                    ).copyWith(fontStyle: deleted ? FontStyle.italic : FontStyle.normal),
                  ),
                ),
                const SizedBox(height: 2),
                _MetaRow(message: message, isMe: isMe),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  const _MetaRow({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final time = _time(message.createdAt);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _statusIcon(colorScheme),
        ],
      ],
    );
  }

  Widget _statusIcon(ColorScheme colorScheme) {
    if (message.status == 'sending') {
      return Icon(Icons.access_time, size: 12, color: colorScheme.onSurfaceVariant);
    }
    if (message.status == 'read') {
      return Icon(Icons.done_all, size: 14, color: colorScheme.primary);
    }
    if (message.status == 'delivered') {
      return Icon(Icons.done_all, size: 14, color: colorScheme.onSurfaceVariant);
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
