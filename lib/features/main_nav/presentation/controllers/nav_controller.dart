import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/home/presentation/pages/home_navigator.dart';

class NavController extends GetxController {
  final currentIndex = 0.obs;
  final drawerPage = Rxn<Widget>();
  final drawerTitle = RxnString();

  void changeIndex(int index) {
    if (index == 0) {
      HomeNavigator.reset();
    }

    closeDrawer();
    currentIndex.value = index;
  }

  void openDrawerPage(Widget page, {required String title}) {
    drawerPage.value = page;
    drawerTitle.value = title;
  }

  void closeDrawer() {
    drawerPage.value = null;
    drawerTitle.value = null;
  }

  void resetIndex() {
    currentIndex.value = 0;
  }
}
