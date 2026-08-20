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
import 'package:loci/shared/widgets/confirm_dialog.dart';

/// Side navigation drawer for the main shell with modern, overflow-safe styling.
///
/// Layout is pinned top and bottom:
/// - Top: Modern elevated profile header with avatar, name, email, and role badge.
/// - Middle: Scrollable list of sleek navigation cards with category icons.
/// - Bottom: Pinned Sign Out action and app version label.
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
    final colors = context.colorScheme;

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
      backgroundColor: colors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          /// ── 1. Modern Profile Header (Pinned) ───────────────────
          _buildHeader(context),

          /// ── 2. Scrollable Navigation Menu ───────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: scrollableItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) =>
                  _buildTile(context, scrollableItems[index]),
            ),
          ),

          /// ── 3. Pinned Bottom Actions (Sign Out & Version) ───────
          if (pinnedItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...pinnedItems.map((item) => _buildTile(context, item)),
                    const SizedBox(height: 6),
                    Text(
                      'Loci App v1.0.0',
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Top header showing current user avatar, name, email and role badge with zero-overflow safety.
  Widget _buildHeader(BuildContext context) {
    final authController = Get.find<AuthController>();
    final colors = context.colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Obx(() {
      final user = authController.userModel;
      final userName =
          (user?.name ?? '').trim().isNotEmpty ? user!.name : 'Guest User';
      final userEmail = (user?.email ?? '').trim();
      final role = user?.role;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(18, topPadding + 16, 18, 18),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          border: Border(
            bottom: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            /// Avatar with rounded ring border
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: ChatAvatar(
                name: userName,
                avatarUrl: user?.avatar,
                size: 52,
              ),
            ),

            const SizedBox(width: 14),

            /// Name + Email + Role Badge (Wrapped in Expanded for zero-overflow)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textMd(
                      color: colors.onSurface,
                      weight: FontWeight.w700,
                    ),
                  ),
                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),

                  /// Styled Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _roleLabel(role),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textXs(
                        color: colors.primary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Single drawer row with modern rounded card hover styling.
  Widget _buildTile(BuildContext context, Map<String, dynamic> item) {
    final colors = context.colorScheme;
    final isDanger = item['isDanger'] ?? false;
    final isSubscription = item['title'] == 'Subscription';
    final Color textColor = isDanger ? Colors.red : colors.onSurface;
    final Color iconColor = isDanger ? Colors.red : colors.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleItem(context, item['title']),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              /// Leading Icon Container
              Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDanger
                      ? Colors.red.withValues(alpha: 0.1)
                      : colors.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/icons/${item["icon"]}.svg',
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),

              const SizedBox(width: 14),

              /// Title (Wrapped in Expanded for zero-overflow)
              Expanded(
                child: Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textSm(
                    color: textColor,
                    weight: isDanger ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),

              /// Pro / Crown Badge for Subscription
              if (isSubscription)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'PRO',
                    style: AppTextStyle.textXs(
                      color: const Color(0xFFD4AF37),
                      weight: FontWeight.w700,
                    ),
                  ),
                ),

              /// Trailing Chevron
              if (!isDanger)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                ),
            ],
          ),
        ),
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
  void _handleItem(BuildContext context, String title) {
    FocusScope.of(context).unfocus();
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
        _showSignOutConfirmation(context);
        break;
    }
  }

  Future<void> _showSignOutConfirmation(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      icon: Icons.logout_rounded,
      isDestructive: true,
    );

    if (confirmed) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      Get.find<AuthController>().logout();
    }
  }
}
