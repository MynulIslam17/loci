import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/my_search_delegate.dart';

/// Top app bar for the main shell: drawer button, user greeting and the
/// search / chat / notification actions. Shows a contextual title + back
/// when a drawer overlay list is open.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  static const double _toolbarHeight = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  String _firstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'there';
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final navController = Get.find<NavController>();
    // Finding it here (fenix binding) also starts the conversation fetch and
    // socket listeners at app start, so the badge is live before the chat
    // list is ever opened.
    final chatListController = Get.find<ChatListController>();

    return Obx(() {
      final isDrawerOpen = navController.drawerPage.value != null;
      final drawerTitle = navController.drawerTitle.value ?? '';

      return AppBar(
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 3,
        toolbarHeight: _toolbarHeight,
        leading: isDrawerOpen
            ? IconButton(
                onPressed: navController.closeDrawer,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
        title: Text(
          isDrawerOpen && drawerTitle.isNotEmpty
              ? drawerTitle
              : "Hello ${_firstName(authController.userModel?.name)} !",
          style: AppTextStyle.textLg(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        actions: isDrawerOpen
            ? null
            : [
                IconButton(
                  onPressed: () =>
                      showSearch(context: context, delegate: MySearchDelegate()),
                  icon: const Icon(Icons.search_rounded),
                ),
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.chatList),
                  icon: Badge.count(
                    count: chatListController.totalUnread,
                    isLabelVisible: chatListController.totalUnread > 0,
                    child: const Icon(Icons.forum_outlined),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.notification),
                  icon: const Icon(Icons.notifications_outlined),
                ),
                const SizedBox(width: 4),
              ],
      );
    });
  }
}
