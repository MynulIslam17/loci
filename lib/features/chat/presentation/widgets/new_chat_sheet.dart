import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/chat/presentation/controllers/new_chat_controller.dart';
import 'package:loci/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

/// "New chat" picker: lists the user's connections (the only people they can
/// message) and opens the direct conversation on tap.
class NewChatSheet extends StatefulWidget {
  const NewChatSheet({super.key});

  /// Opens the picker above the chat list.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewChatSheet(),
    );
  }

  @override
  State<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<NewChatSheet> {
  late final NewChatController controller;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Long-lived (registered in AppBindings): keeps connections cached across
    // opens, so reopening shows them instantly instead of refetching.
    controller = Get.find<NewChatController>();
    controller.searchQuery.value = '';
    controller.ensureLoaded();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openChat(ConnectionModel connection) async {
    final conversation = await controller.startChat(connection);
    if (conversation == null || !mounted) return;

    Navigator.pop(context);
    Get.toNamed(
      AppRoutes.message,
      arguments: {
        'conversationId': conversation.id,
        'otherId': connection.userId.isNotEmpty
            ? connection.userId
            : connection.id,
        'otherName': connection.name,
        'otherAvatar': connection.avatar.isEmpty ? null : connection.avatar,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Text(
                  'New chat',
                  style: AppTextStyle.textMd(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomTextField(
              controller: _search,
              hintText: 'Search connections',
              borderColor: colorScheme.outline,
              fontSize: 14,
              textColor: colorScheme.onSurface,
              hintTextColor: colorScheme.onSurfaceVariant,
              onChanged: controller.onSearchChanged,
              showClearButton: true,
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.errorMessage.value != null &&
                  controller.connections.isEmpty) {
                return ErrorStateWidget(
                  message: controller.errorMessage.value!,
                  onRetry: controller.fetchConnections,
                );
              }

              final items = controller.filteredConnections;
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: controller.searchQuery.value.isEmpty
                      ? 'No connections yet'
                      : 'No connections match your search',
                  subtitle: controller.searchQuery.value.isEmpty
                      ? 'Connect with people to start chatting'
                      : null,
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildTile(items[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(ConnectionModel connection) {
    final colorScheme = context.colorScheme;
    final userId =
        connection.userId.isNotEmpty ? connection.userId : connection.id;

    return Obx(() {
      final starting = controller.startingUserId.value == userId;
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: ChatAvatar(
          name: connection.name,
          avatarUrl: connection.avatar.isEmpty ? null : connection.avatar,
          size: 44,
        ),
        title: Text(
          connection.name,
          style: AppTextStyle.textSm(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        subtitle: connection.organization.isEmpty
            ? null
            : Text(
                connection.organization,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
              ),
        trailing: starting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: colorScheme.primary,
              ),
        onTap: starting ? null : () => _openChat(connection),
      );
    });
  }
}
