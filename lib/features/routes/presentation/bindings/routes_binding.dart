import 'package:get/get.dart';
import 'package:loci/features/routes/domain/services/routes_service.dart';
import 'package:loci/features/routes/presentation/controllers/route_details_controller.dart';

class RoutesBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<RoutesService>();
    Get.lazyPut(() => RouteDetailsController(service));
  }
}

/// Backward-compatible alias for route bindings.
typedef RoutesBindings = RoutesBinding;
