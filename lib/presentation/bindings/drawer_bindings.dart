import 'package:get/get.dart';
import 'package:loci/presentation/controllers/qr_code/get_my_qr_controller.dart';

class DrawerBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut(()=>GetMyQrCodeController());

  }
}
