import 'package:get/get.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffle_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffles_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/create_activity_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/event_edit_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/route_edit_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/raffle_edit_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/view_activity_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/task_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/total_checkin_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/total_rsvp_controller.dart';

class ExploreActivityBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<ExploreActivityService>();

    Get.lazyPut(() => CreateActivityController(service), fenix: true);

    Get.lazyPut(() => TaskController(service));

    Get.lazyPut(() => BusinessEventListController(service));
    Get.lazyPut(() => BusinessRouteListController(service));
    Get.lazyPut(() => BusinessRafflesListController(service));

    Get.lazyPut(() => BusinessEventDetailsController(service));
    Get.lazyPut(() => BusinessRouteDetailsController(service));
    Get.lazyPut(() => BusinessRaffleDetailsController(service));

    Get.lazyPut(() => EventEditController(service), fenix: true);
    Get.lazyPut(() => RouteEditController(service), fenix: true);
    Get.lazyPut(() => RaffleEditController(service), fenix: true);
    Get.lazyPut(() => ViewActivityController(), fenix: true);

    Get.lazyPut(() => TotalRsvpController(service), fenix: true);
    Get.lazyPut(() => TotalCheckinController(service), fenix: true);
  }
}

/// Backward-compatible alias for route bindings.
typedef ExploreActivityBindings = ExploreActivityBinding;
