import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';
import 'package:loci/features/main_nav/presentation/widgets/app_navigation_drawer.dart';
import 'package:loci/features/main_nav/presentation/widgets/ios_glass_bottom_nav_bar.dart';
import 'package:loci/features/main_nav/presentation/widgets/main_app_bar.dart';
import 'package:loci/features/main_nav/presentation/widgets/main_bottom_nav_bar.dart';

import 'package:loci/features/browse_business/presentation/pages/browse_screen.dart';
import 'package:loci/features/event/presentation/pages/event_screen.dart';
import 'package:loci/features/home/presentation/pages/home_navigator.dart';
import 'package:loci/features/network/presentation/pages/network_screen.dart';
import 'package:loci/features/profile/presentation/pages/profile_screen.dart';

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

  /// Tabs the user has actually opened. A tab is only built (and its
  /// initial API call fired) the first time it's visited; after that it
  /// stays mounted so switching back is instant with no reload.
  /// Home (index 0) is the default tab, so it starts loaded.
  final Set<int> _loadedIndices = {0};

  @override
  Widget build(BuildContext context) {
    // Free vertical space for composers (home/community post field) so the
    // keyboard does not trap the expanded poll/post toolbar under the nav bar.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      resizeToAvoidBottomInset: true,
      // iOS glass bar is overlaid so tab content can show through it.
      extendBody: isIOS,

      /// Left drawer menu
      drawer: const AppNavigationDrawer(),

      /// Top app bar
      appBar: const MainAppBar(),

      /// Main screen body
      body: isIOS
          ? _buildIosBody(context, keyboardOpen: keyboardOpen)
          : _buildBody(context),

      /// Android keeps the existing Material bar. iOS overlays the native
      /// glass tab bar on the body instead so content can bleed through.
      bottomNavigationBar: (!isIOS && !keyboardOpen)
          ? const MainBottomNavBar()
          : null,
    );
  }

  /// Native glass tab bar sits on top of the tabs (sample pattern) so the
  /// Liquid Glass can sample the screen behind it.
  Widget _buildIosBody(BuildContext context, {required bool keyboardOpen}) {
    return Stack(
      children: [
        Positioned.fill(
          child: _withIosTabInset(
            context,
            keyboardOpen: keyboardOpen,
            child: _buildBody(context),
          ),
        ),
        if (!keyboardOpen)
          const Align(
            alignment: Alignment.bottomCenter,
            child: IosGlassBottomNavBar(),
          ),
      ],
    );
  }

  /// Lets lists / SafeArea keep last items above the glass bar without
  /// covering the pixels the bar needs to blur.
  ///
  /// IMPORTANT: We always return a `MediaQuery` widget regardless of keyboard
  /// state so the child element tree structure stays stable. If we returned
  /// `child` directly when the keyboard is open, Flutter would see the
  /// `Positioned.fill` child change from `MediaQuery` → `PopScope`, unmount
  /// the entire subtree, and destroy all FocusNode / scroll / text state in
  /// the tab screens.
  Widget _withIosTabInset(
    BuildContext context, {
    required bool keyboardOpen,
    required Widget child,
  }) {
    final mq = MediaQuery.of(context);
    if (keyboardOpen) {
      // Pass through the original MediaQuery data unchanged, but keep
      // the MediaQuery widget in the tree for stable element reconciliation.
      return MediaQuery(data: mq, child: child);
    }
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: IosGlassBottomNavBar.height),
        viewPadding: mq.viewPadding.copyWith(
          bottom: IosGlassBottomNavBar.height,
        ),
      ),
      child: child,
    );
  }

  //---------------- WIDGET METHODS ----------------

  /// Main body that switches screens based on selected tab
  Widget _buildBody(BuildContext context) {
    return PopScope(
      canPop: false,

      /// Custom back button handling
      onPopInvokedWithResult: (didPop, result) {
        /// If a drawer overlay page is open, close it first.
        if (navController.drawerPage.value != null) {
          navController.closeDrawer();
          return;
        }

        /// If Home tab has nested navigation
        if (HomeNavigator.navigatorKey.currentState?.canPop() == true) {
          HomeNavigator.navigatorKey.currentState?.pop();
          return;
        }

        /// If not on Home tab, go to Home
        if (navController.currentIndex.value != 0) {
          navController.changeIndex(0);
          return;
        }

        /// Exit app
        SystemNavigator.pop();
      },

      /// Screen content (bottom inset handled globally + bottom nav bar)
      child: Obx(() {
        /// Lazy IndexedStack: a tab is built only once it's first visited,
        /// then kept mounted so switching back is instant with no reload
        /// (no repeated API calls / loaders on tab switch). Unvisited tabs
        /// stay as empty placeholders and fetch nothing until opened.
        /// A drawer page, when open, overlays the tabs without disposing them.
        final index = navController.currentIndex.value;
        final page = navController.drawerPage.value;
        _loadedIndices.add(index);
        final isOverlayOpen = page != null;

        return Stack(
          fit: StackFit.expand,
          children: [
            /// Tabs stay mounted (state preserved) but are taken offstage
            /// while an overlay page is open, so their scrollables aren't
            /// laid out beneath it. This avoids two stretch-overscroll
            /// scrollables sharing the same space (which triggered the
            /// "_StretchController: Build scheduled during frame" error) and
            /// stops the underlying tab from showing through the overlay.
            Offstage(
              offstage: isOverlayOpen,
              child: IndexedStack(
                index: index,
                children: List.generate(
                  _screens.length,
                  (i) => _loadedIndices.contains(i)
                      ? _screens[i]
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            /// Drawer overlay page — opaque surface so nothing shows through.
            if (isOverlayOpen)
              Positioned.fill(
                child: Material(
                  color: context.colorScheme.surface,
                  child: page,
                ),
              ),
          ],
        );
      }),
    );
  }

}
