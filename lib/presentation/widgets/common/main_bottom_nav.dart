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

  /// GetX controller that manages bottom navigation and drawer pages
  final navController = Get.find<NavController>();

  /// Main screens used in bottom navigation
  final List<Widget> _screens = [
    const HomeNavigator(),
    BrowseScreen(),
    EventScreen(),
    NetworkScreen(),
    ProfileScreen(),
  ];

  /// Drawer menu items
  /// Each item contains title + icon name
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

  /// Bottom navigation tabs
  /// Each tab contains title + inactive icon + active icon
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

      /// Left drawer menu
      drawer: _buildDrawer(context),

      /// Top app bar
      appBar: _buildAppBar(context),

      /// Main screen body
      body: _buildBody(),

      /// Bottom navigation bar
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  //---------------- WIDGET METHODS ----------------

  /// Drawer widget containing header + menu items
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: context.colorScheme.surface,
      child: Column(
        children: [
          /// Drawer user profile header
          _buildDrawerHeader(context),

          /// Drawer menu list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _drawerMenuItems.length,
              itemBuilder: (context, index) {

                final item = _drawerMenuItems[index];

                /// Some items like "Sign Out" are marked dangerous (red color)
                final isDanger = item['isDanger'] ?? false;

                return ListTile(

                  /// When drawer item tapped
                  onTap: () => _handleDrawerItem(item['title']),

                  /// Drawer icon
                  leading: SvgPicture.asset(
                    'assets/icons/${item["icon"]}.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDanger ? Colors.red : context.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),

                  /// Drawer title
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

  /// Drawer top header showing user info
  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      color: context.colorScheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        children: [

          /// User profile image
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(Assets.images.user1.path),
          ),

          const SizedBox(width: 20),

          /// User name + business name
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

  /// App bar displayed at top of screen
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.5),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 3,
      toolbarHeight: 64,

      /// Menu button that opens drawer
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
      ),

      /// Greeting title
      title: Text(
        "Hello Mynul !",
        style: AppTextStyle.textLg(
          color: context.colorScheme.onSurface,
          weight: FontWeight.w600,
        ),
      ),

      /// App bar action icons
      actions: [
        IconButton(
          onPressed: () => _handleAppBarAction("search"),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          onPressed: () => _handleAppBarAction("chat"),
          icon: const Icon(Icons.forum_outlined),
        ),
        IconButton(
          onPressed: () => _handleAppBarAction("notification"),
          icon: const Icon(Icons.notifications_outlined),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// Main body that switches screens based on selected tab
  Widget _buildBody() {
    return PopScope(
      canPop: false,

      /// Custom back button handling
      onPopInvokedWithResult: (didPop, result) {

        /// If a drawer page is open
        if (navController.drawerPage != null) {

          final nestedNav = navController.drawerNavigatorKey?.currentState;

          /// Pop nested navigation first
          if (nestedNav != null && nestedNav.canPop()) {
            nestedNav.pop();
          } else {

            /// Otherwise close drawer page
            navController.drawerPage = null;
            navController.drawerNavigatorKey = null;
            navController.update();
          }
          return;
        }

        /// If Home tab has nested navigation
        if (HomeNavigator.navigatorKey.currentState?.canPop() == true) {
          HomeNavigator.navigatorKey.currentState?.pop();
          return;
        }

        /// If not on Home tab, go to Home
        if (navController.currentIndex != 0) {
          navController.changeIndex(0);
          return;
        }

        /// Exit app
        SystemNavigator.pop();
      },

      /// Screen content
      child: SafeArea(
        child: GetBuilder<NavController>(
          builder: (controller) {
            return controller.drawerPage ?? _screens[controller.currentIndex];
          },
        ),
      ),
    );
  }

  /// Custom bottom navigation bar
  Widget _buildCustomBottomNav(BuildContext context) {
    return GetBuilder<NavController>(
      builder: (controller) {

        /// If drawer page opened hide active state
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

          /// Bottom nav items
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {

              final tab = _tabs[index];

              /// Check if tab is selected
              final isSelected =
                  !isDrawerOpen && controller.currentIndex == index;

              return GestureDetector(

                /// Change tab when tapped
                onTap: () => controller.changeIndex(index),
                behavior: HitTestBehavior.translucent,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// Tab icon
                    Icon(
                      isSelected ? tab['activeIcon'] : tab['icon'],
                      size: isSelected ? 27 : 22,
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),

                    /// Tab label
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

  /// Handles drawer item navigation
  void _handleDrawerItem(String title) {
    Get.back();

    switch (title) {

      case "Recent Activity":
        Get.toNamed(AppRoutes.recentActivity);
        break;

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

      case "QR Code":
        Get.toNamed(AppRoutes.checkIn);
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

      case "Subscription" :
        Get.toNamed(AppRoutes.subscription);
        break;
    }
  }

  /// Handles app bar action buttons
  void _handleAppBarAction(String action) {
    switch (action) {

      case "search":
      // TODO: open search screen

        break;

      case "chat":
      // TODO: open chat screen
        Get.toNamed(AppRoutes.chatList);
        break;

      case "notification":
      // TODO: open notification screen
        Get.toNamed(AppRoutes.notification);
        break;
    }
  }
}