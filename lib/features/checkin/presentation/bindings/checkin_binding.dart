import 'package:get/get.dart';
import 'package:loci/features/checkin/presentation/controllers/check_in_controller.dart';
import 'package:loci/features/common/domain/services/common_service.dart';

class CheckinBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<CommonService>();
    Get.lazyPut(() => CheckInController(service), fenix: true);
  }
}
