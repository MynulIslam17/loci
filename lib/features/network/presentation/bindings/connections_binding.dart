import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/connections_controller.dart';

class ConnectionsBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<NetworkService>();
    Get.lazyPut(() => ConnectionsController(service), fenix: true);
  }
}
