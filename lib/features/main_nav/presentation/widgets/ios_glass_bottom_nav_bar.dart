import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';

/// Native iOS Liquid Glass tab bar (UIKit platform view).
///
/// Overlay this at the bottom of the shell so content can show through the
/// glass. Android keeps [MainBottomNavBar] instead.
class IosGlassBottomNavBar extends StatelessWidget {
  const IosGlassBottomNavBar({super.key});

  /// Includes the home-indicator region, matching the native tab bar sample.
  static const double height = 85;

  static const List<CNTabBarItem> _items = [
    CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
    CNTabBarItem(label: 'Browse', icon: CNSymbol('magnifyingglass')),
    CNTabBarItem(label: 'Event', icon: CNSymbol('calendar')),
    CNTabBarItem(label: 'Network', icon: CNSymbol('person.3.fill')),
    CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle.fill')),
  ];

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavController>();
    final tint = context.colorScheme.primary;

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
        primaryColor: tint,
      ),
      child: Obx(
        () => CNTabBar(
          items: _items,
          currentIndex: navController.currentIndex.value,
          tint: tint,
          height: height,
          onTap: navController.changeIndex,
        ),
      ),
    );
  }
}
