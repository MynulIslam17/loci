import 'package:get/get.dart';
import 'package:loci/features/event/domain/services/event_service.dart';
import 'package:loci/features/event/presentation/controllers/event_list_controller.dart';
import 'package:loci/features/home/presentation/bindings/home_binding.dart';
import 'package:loci/features/network/presentation/bindings/network_dashboard_binding.dart';
import 'package:loci/features/notification/domain/services/notification_service.dart';
import 'package:loci/features/notification/presentation/controllers/notification_controller.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';
import 'package:loci/features/profile/presentation/controllers/profile_controller.dart';
import 'package:loci/features/raffles/presentation/bindings/raffles_binding.dart';
import 'package:loci/features/routes/domain/services/routes_service.dart';
import 'package:loci/features/routes/presentation/controllers/route_details_controller.dart';
import 'package:loci/features/routes/presentation/controllers/route_list_controller.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    final eventService = Get.find<EventService>();
    final routesService = Get.find<RoutesService>();

    Get.lazyPut(() => EventListController(eventService), fenix: true);
    Get.lazyPut(() => RouteListController(routesService), fenix: true);
    Get.lazyPut(() => RouteDetailsController(routesService));
    RafflesBinding().dependencies();

    Get.lazyPut(() => ProfileController(Get.find<ProfileService>()));
    NetworkDashboardBinding().dependencies();
    HomeBinding().dependencies();
    Get.lazyPut(
      () => NotificationController(Get.find<NotificationService>()),
      fenix: true,
    );
  }
}
