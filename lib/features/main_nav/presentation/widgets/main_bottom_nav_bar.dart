import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';

/// Custom bottom navigation bar for the main shell.
///
/// The active tab is suppressed while a drawer overlay page is open, so no
/// tab looks selected when the user is on a raffle/route overlay.
class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key});

  /// Tabs — title + inactive icon + active icon. Index matches the body's
  /// [IndexedStack] order (Home, Browse, Event, Network, Profile).
  static const List<Map<String, dynamic>> _tabs = [
    {
      'title': 'Home',
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
    },
    {
      'title': 'Browse',
      'icon': Icons.search_outlined,
      'activeIcon': Icons.search_rounded,
    },
    {
      'title': 'Event',
      'icon': Icons.calendar_month_outlined,
      'activeIcon': Icons.calendar_month_rounded,
    },
    {
      'title': 'Network',
      'icon': Icons.groups_outlined,
      'activeIcon': Icons.groups_rounded,
    },
    {
      'title': 'Profile',
      'icon': Icons.person_outline,
      'activeIcon': Icons.person_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavController>();

    return Obx(() {
      /// While a drawer overlay page is open, no tab is highlighted.
      final isDrawerOpen = navController.drawerPage.value != null;
      final currentIndex = navController.currentIndex.value;

      return Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 4),

        /// Bottom nav items
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = !isDrawerOpen && currentIndex == index;

            return GestureDetector(
              onTap: () => navController.changeIndex(index),
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
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
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
    });
  }
}
