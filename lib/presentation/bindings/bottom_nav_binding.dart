import 'package:get/get.dart';

import '../controllers/event/event_list_controller.dart';
import '../controllers/routes/route_details_controller.dart';
import '../controllers/routes/route_list_controller.dart';

class BottomNavBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => EventListController());
    Get.lazyPut(() => RouteListController());
    Get.lazyPut(() => RouteDetailsController());
  }
}