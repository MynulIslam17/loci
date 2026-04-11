import 'package:get/get.dart';
import 'package:loci/presentation/controllers/common/check_in_controller.dart';
import 'package:loci/presentation/controllers/common/manual_checkin.dart';
import 'package:loci/presentation/controllers/event/rsvp_controller.dart';

import '../controllers/event/event_list_controller.dart';
import '../controllers/routes/route_details_controller.dart';
import '../controllers/routes/route_list_controller.dart';

class BottomNavBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => EventListController(),fenix: true);
    Get.lazyPut(() => RouteListController());
    Get.lazyPut(() => RouteDetailsController());
    Get.lazyPut(() => RSVPController(),fenix: true);
    Get.lazyPut(() => CheckInController(),fenix: true);
    Get.lazyPut(() => ManualCheckInController(),fenix: true);

  }
}