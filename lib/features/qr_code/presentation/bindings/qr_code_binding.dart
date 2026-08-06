import 'package:get/get.dart';
import 'package:loci/features/qr_code/domain/services/qr_code_service.dart';
import 'package:loci/features/qr_code/presentation/controllers/my_qr_code_controller.dart';

class QrCodeBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<QrCodeService>();
    if (!Get.isRegistered<MyQrCodeController>()) {
      Get.put(MyQrCodeController(service), permanent: true);
    }
  }
}
