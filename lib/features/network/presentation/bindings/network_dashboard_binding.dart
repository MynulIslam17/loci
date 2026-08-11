import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/network_dashboard_controller.dart';

class NetworkDashboardBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<NetworkService>();
    Get.lazyPut(() => NetworkDashboardController(service), fenix: true);
  }
}
