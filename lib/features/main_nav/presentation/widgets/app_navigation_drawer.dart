import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';
import 'package:loci/features/raffles/presentation/pages/active_raffles_screen.dart';
import 'package:loci/features/routes/presentation/pages/explore_routes_screen.dart';
import 'package:loci/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:loci/routes/app_routes.dart';

/// Side navigation drawer for the main shell.
///
/// Layout is pinned top and bottom: the profile header stays fixed at the
/// top and the "Sign Out" action stays fixed at the bottom, while only the
/// middle menu options scroll between them.
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  /// Menu entries — title + icon asset name. Items flagged `isDanger`
  /// (Sign Out) render in red and are pinned to the bottom.
  static const List<Map<String, dynamic>> _menuItems = [
    {'title': 'My QR-Code', 'icon': 'qr_code'},
    {'title': 'Explore Routes', 'icon': 'map'},
    {'title': 'Upcoming Events', 'icon': 'calander'},
    {'title': 'Active Raffles', 'icon': 'rafel'},
    {'title': 'Recent Activity', 'icon': 'paper'},
    {'title': 'Business Profiles', 'icon': 'building'},
    {'title': 'Subscription', 'icon': 'qrown', 'requiresSubscription': true},
    {'title': 'About App', 'icon': 'about'},
    {'title': 'Settings', 'icon': 'setting'},
    {'title': 'Terms & Conditions', 'icon': 'paper'},
    {'title': 'Sign Out', 'icon': 'logout', 'isDanger': true},
  ];

  @override
  Widget build(BuildContext context) {
    // Members (role `user`) can't use subscriptions — hide that entry until a
    // business claim promotes them to business_owner.
    final canSubscribe = Get.find<AuthController>().canAccessSubscription;

    /// Everything except the pinned danger action (Sign Out) scrolls.
    final scrollableItems = _menuItems
        .where((item) => item['isDanger'] != true)
        .where(
          (item) => item['requiresSubscription'] != true || canSubscribe,
        )
        .toList();
    final pinnedItems = _menuItems
        .where((item) => item['isDanger'] == true)
        .toList();

    return Drawer(
      backgroundColor: context.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            /// Profile header (pinned)
            _buildHeader(context),

            /// Scrollable menu list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: scrollableItems.length,
                itemBuilder: (context, index) =>
                    _buildTile(context, scrollableItems[index]),
              ),
            ),

            /// Pinned actions at the bottom (Sign Out)
            if (pinnedItems.isNotEmpty) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.4,
                ),
              ),
              ...pinnedItems.map((item) => _buildTile(context, item)),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  /// Top header showing the current user's avatar, name and role.
  Widget _buildHeader(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.userModel;

      return Container(
        width: double.infinity,
        height: 160,
        color: context.colorScheme.surfaceContainer,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Row(
          children: [
            /// User profile image — cached + initials fallback when no photo.
            ChatAvatar(
              name: (user?.name ?? '').isNotEmpty ? user!.name : 'Guest',
              avatarUrl: user?.avatar,
              size: 56,
            ),

            const SizedBox(width: 20),

            /// User name + role
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (user?.name ?? '').isNotEmpty ? user!.name : 'Guest',
                  style: AppTextStyle.textLg(
                    color: context.colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  _roleLabel(user?.role),
                  style: AppTextStyle.textXs(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Single drawer row. Items flagged `isDanger` (e.g. Sign Out) render in red.
  Widget _buildTile(BuildContext context, Map<String, dynamic> item) {
    final isDanger = item['isDanger'] ?? false;
    final color = isDanger ? Colors.red : context.colorScheme.onSurface;

    return ListTile(
      onTap: () => _handleItem(item['title']),
      leading: SvgPicture.asset(
        'assets/icons/${item["icon"]}.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
      title: Text(
        item['title'],
        style: AppTextStyle.textSm(color: color, weight: FontWeight.w500),
      ),
    );
  }

  /// Human-readable label for a user's role (header subtitle).
  String _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'business_owner':
        return 'Business Owner';
      case 'user':
      default:
        return 'Member';
    }
  }

  /// Routes a tapped drawer item. Closes the drawer first, then navigates.
  void _handleItem(String title) {
    Get.back();

    final navController = Get.find<NavController>();

    switch (title) {
      case "Recent Activity":
        Get.toNamed(AppRoutes.recentActivity);
        break;

      case "Explore Routes":
        navController.openDrawerPage(
          const ExploreRoutesPage(),
          title: 'Explore Routes',
        );
        break;

      case "Active Raffles":
        navController.openDrawerPage(
          const ActiveRafflesPage(),
          title: 'Active Raffles',
        );
        break;

      case "My QR-Code":
        Get.toNamed(AppRoutes.myQrCode);
        break;

      case "Business Profiles":
        Get.toNamed(AppRoutes.searchBusiness);
        break;

      case "Upcoming Events":
        navController.changeIndex(2);
        break;

      case 'Terms & Conditions':
        Get.toNamed(AppRoutes.terms);
        break;

      case 'Settings':
        Get.toNamed(AppRoutes.settings);
        break;

      case 'About App':
        Get.toNamed(AppRoutes.about);
        break;

      case "Subscription":
        Get.toNamed(AppRoutes.subscription);
        break;

      case "Sign Out":
        Get.find<AuthController>().logout();
        break;
    }
  }
}
