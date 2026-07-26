import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/MySearchDelegate.dart';

/// Top app bar for the main shell: drawer button, user greeting and the
/// search / chat / notification actions.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  static const double _toolbarHeight = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  /// First name only, for the greeting.
  String _firstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'there';
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AppBar(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 3,
      toolbarHeight: _toolbarHeight,

      /// Menu button that opens drawer
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
      ),

      /// Greeting title
      title: Obx(
        () => Text(
          "Hello ${_firstName(authController.userModel?.name)} !",
          style: AppTextStyle.textLg(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
      ),

      /// App bar action icons
      actions: [
        IconButton(
          onPressed: () =>
              showSearch(context: context, delegate: MySearchDelegate()),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.chatList),
          icon: const Icon(Icons.forum_outlined),
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.notification),
          icon: const Icon(Icons.notifications_outlined),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
