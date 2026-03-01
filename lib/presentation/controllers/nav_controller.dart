import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NavController extends GetxController {
  int _currentIndex = 0;
  Widget ? drawerPage; // active drawer screen

  int get currentIndex => _currentIndex;


  void changeIndex(int index) {
     drawerPage=null; //--set drawer page null when used bottomNav item(remove page)
    _currentIndex = index;
    update();
  }

  //-- this method will use for set drawer pages to the bottom nav
  void openDrawerPage(Widget page){

    drawerPage=page;
    update();
  }


  void resetIndex() {
    _currentIndex = 0;
    update();
  }
}