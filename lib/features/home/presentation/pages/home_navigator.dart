import 'package:flutter/material.dart';
import 'home_screen.dart';

/// Nested navigator for the Home tab.
///
/// Home currently has no in-tab sub-routes — feature sections (Communities,
/// etc.) open as full-screen pages on the root navigator so they get their own
/// app bar/back button without the bottom nav. The navigator and [navigatorKey]
/// are kept because the main shell's back handling and [reset] rely on them.
class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  static void reset() {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
