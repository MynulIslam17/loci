import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/nav_controller.dart';
import 'package:loci/presentation/pages/explore_routes/explore_routes_screen.dart';
import 'package:loci/presentation/pages/raffles/active_raffles_screen.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../gen/assets.gen.dart';
import '../../pages/browse/browse_screen.dart';
import '../../pages/event/event_screen.dart';
import '../../pages/home/home_screen.dart';
import '../../pages/network/network_screen.dart';
import '../../pages/profile/profile_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  final navController = Get.find<NavController>();

  final List<Widget> _screens = [
    HomeScreen(),
    BrowseScreen(),
    EventScreen(),
    NetworkScreen(),
    ProfileScreen(),
  ];

  final List<Map<String, dynamic>> _drawerMenuItems = [
    {'title': 'QR Code', 'icon': 'qr_code'},
    {'title': 'Explore Routes', 'icon': 'map'},
    {'title': 'Upcoming Events', 'icon': 'calander'},
    {'title': 'Active Raffles', 'icon': 'rafel'},
    {'title': 'Recent Activity', 'icon': 'paper'},
    {'title': 'Business Profiles', 'icon': 'building'},
    {'title': 'Subscription', 'icon': 'qrown'},
    {'title': 'About App', 'icon': 'about'},
    {'title': 'Settings', 'icon': 'setting'},
    {'title': 'Terms & Conditions', 'icon': 'paper'},
    {'title': 'Sign Out', 'icon': 'logout', 'isDanger': true},
  ];

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded},
    {'title': 'Browse', 'icon': Icons.search_outlined, 'activeIcon': Icons.search_rounded},
    {'title': 'Event', 'icon': Icons.calendar_month_outlined, 'activeIcon': Icons.calendar_month_rounded},
    {'title': 'Network', 'icon': Icons.groups_outlined, 'activeIcon': Icons.groups_rounded},
    {'title': 'Profile', 'icon': Icons.person_outline, 'activeIcon': Icons.person_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  //---------------- WIDGET METHODS ----------------

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: context.colorScheme.surface,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _drawerMenuItems.length,
              itemBuilder: (context, index) {
                final item = _drawerMenuItems[index];
                final isDanger = item['isDanger'] ?? false;
                return ListTile(
                  onTap: () => _handleDrawerItem(item['title']),
                  leading: SvgPicture.asset(
                    'assets/icons/${item["icon"]}.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDanger ? Colors.red : context.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(
                    item['title'],
                    style: AppTextStyle.textSm(
                      color: isDanger ? Colors.red : context.colorScheme.onSurface,
                      weight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      color: context.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(Assets.images.user1.path),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mynul Islam",
                style: AppTextStyle.textLg(
                  color: context.colorScheme.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
              Text(
                "Business name",
                style: AppTextStyle.textXs(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.5),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 3,
      toolbarHeight: 64,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
      ),
      title: Text(
        "Hello Mynul !",
        style: AppTextStyle.textLg(
          color: context.colorScheme.onSurface,
          weight: FontWeight.w600,
        ),
      ),
      actions: const [
        Icon(Icons.search_rounded),
        SizedBox(width: 8),
        Icon(Icons.forum_outlined),
        SizedBox(width: 8),
        Icon(Icons.notifications_outlined),
        SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (navController.drawerPage != null) {
          final nestedNav = navController.drawerNavigatorKey?.currentState;
          if (nestedNav != null && nestedNav.canPop()) {
            nestedNav.pop();
          } else {
            navController.drawerPage = null;
            navController.drawerNavigatorKey = null;
            navController.update();
          }
          return;
        }
        if (navController.currentIndex != 0) {
          navController.changeIndex(0);
          return;
        }
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: GetBuilder<NavController>(
          builder: (controller) {
            return controller.drawerPage ?? _screens[controller.currentIndex];
          },
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context) {
    return GetBuilder<NavController>(
      builder: (controller) {
        final isDrawerOpen = controller.drawerPage != null;
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = !isDrawerOpen && controller.currentIndex == index;
              return GestureDetector(
                onTap: () => controller.changeIndex(index),
                behavior: HitTestBehavior.translucent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? tab['activeIcon'] : tab['icon'],
                      size: isSelected ? 27 : 22,
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      tab['title'],
                      style: TextStyle(
                        fontSize: isSelected ? 12 : 10,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  void _handleDrawerItem(String title) {
    Get.back();
    switch (title) {
      case "Explore Routes":
        navController.openDrawerPage(
          ExploreRoutesScreen(),
        );
        break;
      case "Active Raffles":
        navController.openDrawerPage(
          ActiveRafflesScreen(),
          navigatorKey: ActiveRafflesScreen.navigatorKey,
        );
        break;

      case "QR Code" :
        Get.toNamed(AppRoutes.checkIn);
        break;
    }


  }
}