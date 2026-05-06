import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import '../../../routes/app_routes.dart';
import '../../bindings/community_binding.dart';
import '../communites/all_community_screen.dart';
import '../communites/community_screen.dart';
import '../communites/create_anouncement_screen.dart';
import 'home_screen.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> push(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> pushWithBinding(
      String routeName, {
        Bindings? binding,
        dynamic arguments,
      }) {
    binding?.dependencies();
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static void reset() {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {

          case AppRoutes.allCommunity:
            CommunityBinding().dependencies();
            return MaterialPageRoute(
              builder: (_) =>  AllCommunityScreen(),
            );

          case AppRoutes.communityScreen:
            final args = settings.arguments as Map<String, dynamic>?;

            final role = args?['communityRole'];
            final communityId = args?['communityId'];

            return MaterialPageRoute(
              settings: settings,
              builder: (_) => CommunityScreen(
                role: role,
                communityId: communityId
              ),
            );

          case AppRoutes.createAnnouncement:
          //  CreateAnnouncementBinding().dependencies();
            return MaterialPageRoute(
              builder: (_) => const CreateAnnouncementScreen(),
            );


          default:
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
        }
      },
    );
  }
}