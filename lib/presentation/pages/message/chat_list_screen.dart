import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/chat/conversation_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';
import 'package:loci/presentation/controllers/chat/chat_list_controller.dart';
import 'package:loci/presentation/pages/message/widgets/chat_avatar.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatListController controller = Get.find<ChatListController>();
  final AuthController _auth = Get.find<AuthController>();
  String _query = '';

  String get _myId => _auth.userModel?.id ?? '';

  @override
  void initState() {
    super.initState();
    controller.fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Chats"),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                hintText: "Search chats",
                borderColor: colorScheme.outline,
                fontSize: 14,
                textColor: colorScheme.onSurface,
                hintTextColor: colorScheme.onSurfaceVariant,
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: GetBuilder<ChatListController>(
                builder: (ctrl) {
                  if (ctrl.isLoading && ctrl.conversations.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (ctrl.errorMessage != null && ctrl.conversations.isEmpty) {
                    return _CenteredMessage(
                      icon: Icons.error_outline,
                      text: ctrl.errorMessage!,
                    );
                  }

                  final items = _filter(ctrl.conversations);
                  if (items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: ctrl.fetchConversations,
                      child: ListView(
                        children: const [
                          SizedBox(height: 160),
                          _CenteredMessage(
                            icon: Icons.chat_bubble_outline,
                            text: "No conversations yet",
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: ctrl.fetchConversations,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          _buildTile(context, ctrl, items[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ConversationModel> _filter(List<ConversationModel> list) {
    if (_query.isEmpty) return list;
    return list.where((c) {
      final name = c.other(_myId)?.name.toLowerCase() ?? '';
      return name.contains(_query);
    }).toList();
  }

  Widget _buildTile(
      BuildContext context, ChatListController ctrl, ConversationModel conv) {
    final colorScheme = context.colorScheme;
    final other = conv.other(_myId);
    final unread = conv.unreadCount;
    final isOnline = other != null && ctrl.isOnline(other.id);

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
        subtitle: Text(
          _previewText(conv),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.textSm(
            color: unread > 0 ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            weight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _timeLabel(conv.lastActivityAt),
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: AppTextStyle.textXs(
                      color: colorScheme.onPrimary,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.outlineVariant),
          ],
        ),
        onTap: () {
          ctrl.clearUnread(conv.id);
          Get.toNamed(AppRoutes.message, arguments: {
            'conversationId': conv.id,
            'otherId': other?.id,
            'otherName': other?.name,
            'otherAvatar': other?.avatar,
          });
        },
      ),
    );
  }

  String _previewText(ConversationModel conv) {
    final lm = conv.lastMessage;
    if (lm == null) return 'Say hello 👋';
    if (lm.isDeleted) return 'Message deleted';
    if ((lm.content ?? '').isEmpty && lm.attachments.isNotEmpty) return '📎 Attachment';
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

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CenteredMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(text, style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
