import 'package:get/get.dart';
import 'package:loci/features/notification/domain/services/notification_service.dart';
import 'package:loci/features/notification/presentation/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<NotificationService>();
    Get.lazyPut(() => NotificationController(service), fenix: true);
  }
}
