import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/home/presentation/pages/home_navigator.dart';

class NavController extends GetxController {
  final currentIndex = 0.obs;
  final drawerPage = Rxn<Widget>();
  final drawerTitle = RxnString();

  void changeIndex(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (index == 0) {
      HomeNavigator.reset();
    }

    closeDrawer();
    currentIndex.value = index;
  }

  void openDrawerPage(Widget page, {required String title}) {
    FocusManager.instance.primaryFocus?.unfocus();
    drawerPage.value = page;
    drawerTitle.value = title;
  }

  void closeDrawer() {
    FocusManager.instance.primaryFocus?.unfocus();
    drawerPage.value = null;
    drawerTitle.value = null;
  }

  void resetIndex() {
    currentIndex.value = 0;
  }
}
