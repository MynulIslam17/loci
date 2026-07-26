import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/connection_controller.dart';

class ConnectionBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<NetworkService>();
    Get.lazyPut(() => ConnectionController(service), fenix: true);
  }
}
