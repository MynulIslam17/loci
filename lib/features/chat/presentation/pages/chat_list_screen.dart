import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:loci/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:loci/features/chat/presentation/widgets/chat_list_shimmer.dart';
import 'package:loci/features/chat/presentation/widgets/new_chat_sheet.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatListController controller = Get.find<ChatListController>();
  final AuthController _auth = Get.find<AuthController>();
  final _searchController = TextEditingController();
  final _query = ''.obs;

  String get _myId => _auth.userModel?.id ?? '';

  @override
  void initState() {
    super.initState();
    controller.fetchConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Chats"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        tooltip: 'New chat',
        onPressed: () => NewChatSheet.show(context),
        child: const Icon(Icons.add_comment_outlined),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                controller: _searchController,
                hintText: "Search chats",
                borderColor: colorScheme.outline,
                fontSize: 14,
                textColor: colorScheme.onSurface,
                hintTextColor: colorScheme.onSurfaceVariant,
                onChanged: (v) => _query.value = v.trim().toLowerCase(),
                showClearButton: true,
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final ctrl = controller;
                final query = _query.value;
                if (ctrl.showInitialShimmer && ctrl.conversations.isEmpty) {
                  return const ChatListShimmer();
                }
                if (ctrl.errorMessage.value != null &&
                    ctrl.conversations.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ctrl.fetchConversations(isRefresh: true),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: ErrorStateWidget(
                              message: ctrl.errorMessage.value!,
                              onRetry: ctrl.fetchConversations,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                final items = _filter(ctrl.conversations.toList(), query);
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ctrl.fetchConversations(isRefresh: true),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: EmptyState(
                              icon: Icons.chat_bubble_outline,
                              title: query.isEmpty
                                  ? 'No conversations yet'
                                  : 'No chats match your search',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                final showBottomLoader = ctrl.isLoadingMore;
                return RefreshIndicator(
                  onRefresh: () => ctrl.fetchConversations(isRefresh: true),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      // Only paginate on the full list; a filtered view has
                      // no meaningful "end of page".
                      if (query.isEmpty &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 300) {
                        ctrl.loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: items.length + (showBottomLoader ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildTile(context, ctrl, items[index]);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<ConversationModel> _filter(List<ConversationModel> list, String query) {
    if (query.isEmpty) return list;
    return list.where((c) {
      final name = c.other(_myId)?.name.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

  Widget _buildTile(
    BuildContext context,
    ChatListController ctrl,
    ConversationModel conv,
  ) {
    final colorScheme = context.colorScheme;
    final other = conv.other(_myId);
    final unread = conv.unreadCount;
    final isOnline = ctrl.isUserActive(other);
    final isTyping = ctrl.isTyping(conv.id);

    return Card(
      elevation: 0.5,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ChatAvatar(
          name: other?.name ?? '',
          avatarUrl: other?.avatar,
          size: 55,
          showOnlineDot: isOnline,
        ),
        title: Text(
          other?.name ?? 'Unknown',
          style: AppTextStyle.textMd(
            color: colorScheme.onSurface,
            weight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            // WhatsApp-style ticks on my own last message.
            if (!isTyping && _lastMessageIsMine(conv)) ...[
              _statusTick(conv.lastMessage!.status, colorScheme),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                isTyping ? 'typing…' : _previewText(conv),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isTyping
                    ? AppTextStyle.textSm(
                        color: colorScheme.primary,
                        weight: FontWeight.w600,
                      ).copyWith(fontStyle: FontStyle.italic)
                    : AppTextStyle.textSm(
                        color: unread > 0
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        weight: unread > 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // WhatsApp-style: the timestamp turns primary when unread.
            Text(
              _timeLabel(conv.lastActivityAt),
              style: AppTextStyle.textXs(
                color: unread > 0
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                weight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: AppTextStyle.textXs(
                    color: colorScheme.onPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
              )
            else
              // Keeps row heights identical whether or not a badge shows.
              const SizedBox(height: 20),
          ],
        ),
        onTap: () {
          ctrl.clearUnread(conv.id);
          Get.toNamed(
            AppRoutes.message,
            arguments: {
              'conversationId': conv.id,
              'otherId': other?.id,
              'otherName': other?.name,
              'otherAvatar': other?.avatar,
              'otherLastSeen': other?.lastSeen,
            },
          );
        },
        onLongPress: () => _confirmDelete(context, ctrl, conv, other?.name),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ChatListController ctrl,
    ConversationModel conv,
    String? otherName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text(
          'This hides the chat with ${otherName ?? 'this user'} for you. '
          'A new message will start the conversation again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ctrl.deleteConversation(conv.id);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  bool _lastMessageIsMine(ConversationModel conv) {
    final lm = conv.lastMessage;
    return lm != null && !lm.isDeleted && lm.sender.id == _myId;
  }

  /// ✓ sent, ✓✓ delivered, blue ✓✓ read — same flow as the message bubbles.
  Widget _statusTick(String status, ColorScheme colorScheme) {
    if (status == 'read') {
      return const Icon(Icons.done_all, size: 15, color: Color(0xFF34B7F1));
    }
    if (status == 'delivered') {
      return Icon(Icons.done_all, size: 15, color: colorScheme.onSurfaceVariant);
    }
    return Icon(Icons.done, size: 15, color: colorScheme.onSurfaceVariant);
  }

  String _previewText(ConversationModel conv) {
    final lm = conv.lastMessage;
    if (lm == null) return 'Say hello 👋';
    if (lm.isDeleted) {
      return lm.sender.id == _myId
          ? 'You unsent a message'
          : '${conv.other(_myId)?.name ?? 'They'} unsent a message';
    }
    // Attachment-only messages have content: null — synthesize the preview
    // from the attachment type (guide §9).
    if ((lm.content ?? '').isEmpty && lm.attachments.isNotEmpty) {
      return switch (lm.attachments.first.type) {
        'image' => '📷 Photo',
        'video' => '🎥 Video',
        'audio' => '🎤 Voice message',
        _ => '📎 File',
      };
    }
    return lm.content ?? '';
  }

  String _timeLabel(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0 && now.day == dt.day) {
      return DateFormat('h:mm a').format(dt);
    }
    if (now.difference(dt).inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('MMM d').format(dt);
  }
}
