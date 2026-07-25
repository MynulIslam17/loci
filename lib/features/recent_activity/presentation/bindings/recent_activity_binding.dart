import 'package:get/get.dart';
import 'package:loci/features/recent_activity/domain/services/recent_activity_service.dart';
import 'package:loci/features/recent_activity/presentation/controllers/recent_activity_controller.dart';

class RecentActivityBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<RecentActivityService>();
    Get.lazyPut(() => RecentActivityController(service));
  }
}
