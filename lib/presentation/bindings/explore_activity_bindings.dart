import 'package:get/get.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_event_details_controller.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_event_list_controller.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_raffle_detils_controller.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_raffles_list_controller.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_route_details_controller.dart';
import 'package:loci/presentation/controllers/explore_acitivity/task_controller.dart';

import '../controllers/explore_acitivity/business_route_list_controller.dart';
import '../controllers/explore_acitivity/business_route_update_controller.dart';
import '../controllers/my_business/create_actvity_controller.dart';

class ExploreActivityBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>CreateActivityController());
    Get.lazyPut(()=>TaskController());

    // TODO : list  of activity controller
    Get.lazyPut(()=>BusinessEventListController());
    Get.lazyPut(()=>BusinessRouteListController());
    Get.lazyPut(()=>BusinessRafflesListController());

    // TODO : view  activity controllers
    Get.lazyPut(()=>BusinessEventDetailsController());
    Get.lazyPut(()=>BusinessRouteDetailsController());
    Get.lazyPut(()=>BusinessRaffleDetailsController());

    // TODO : edit  activity controllers
    Get.lazyPut(()=>BusinessRouteUpdateController());



  }

}