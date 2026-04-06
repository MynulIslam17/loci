import 'package:get/get.dart';

import '../controllers/routes/route_list_controller.dart';

class RoutesBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut(()=>RouteListController());

  }

}