import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavController extends GetxController {
  int _currentIndex = 0;
  Widget? drawerPage;
  GlobalKey<NavigatorState>? drawerNavigatorKey; // ✅ dynamic key

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    drawerPage = null;
    drawerNavigatorKey = null;
    _currentIndex = index;
    update();
  }

  void openDrawerPage(Widget page, {GlobalKey<NavigatorState>? navigatorKey}) {
    drawerPage = page;
    drawerNavigatorKey = navigatorKey;
    update();
  }

  void resetIndex() {
    _currentIndex = 0;
    update();
  }
}