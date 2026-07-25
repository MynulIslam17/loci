import 'package:get/get.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';
import 'package:loci/features/raffles/presentation/controllers/raffle_details_controller.dart';
import 'package:loci/features/raffles/presentation/controllers/raffle_list_controller.dart';

class RafflesBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<RafflesService>();
    Get.lazyPut(() => RaffleListController(service), fenix: true);
    Get.lazyPut(() => RaffleDetailsController(service));
  }
}

/// Backward-compatible alias for route bindings.
typedef RafflesBindings = RafflesBinding;
