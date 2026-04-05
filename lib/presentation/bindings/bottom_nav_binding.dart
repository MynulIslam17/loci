import 'package:get/get.dart';

import '../controllers/event/event_list_controller.dart';

class BottomNavBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => EventListController());
  }
}