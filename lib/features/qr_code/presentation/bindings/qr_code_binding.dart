import 'package:get/get.dart';
import 'package:loci/features/qr_code/domain/services/qr_code_service.dart';
import 'package:loci/features/qr_code/presentation/controllers/get_my_qr_controller.dart';

class QrCodeBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<QrCodeService>();
    Get.lazyPut(() => GetMyQrCodeController(service));
  }
}
