import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/home/presentation/pages/home_navigator.dart';

class NavController extends GetxController {
  final currentIndex = 0.obs;
  final drawerPage = Rxn<Widget>();
  final drawerNavigatorKey = Rxn<GlobalKey<NavigatorState>>();

  void changeIndex(int index) {
    if (index == 0) {
      HomeNavigator.reset();
    }

    drawerPage.value = null;
    drawerNavigatorKey.value = null;
    currentIndex.value = index;
  }

  void openDrawerPage(Widget page, {GlobalKey<NavigatorState>? navigatorKey}) {
    drawerPage.value = page;
    drawerNavigatorKey.value = navigatorKey;
  }

  void resetIndex() {
    currentIndex.value = 0;
  }
}
