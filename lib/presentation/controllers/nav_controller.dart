import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/pages/home/home_screen.dart';

import '../pages/home/home navigator.dart';

class NavController extends GetxController {
  int _currentIndex = 0;
  Widget? drawerPage;
  GlobalKey<NavigatorState>? drawerNavigatorKey; // ✅ dynamic key

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {

    if(index==0){
      HomeNavigator.reset();
    }

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