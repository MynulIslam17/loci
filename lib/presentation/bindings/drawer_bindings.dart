import 'package:get/get.dart';
import 'package:loci/presentation/controllers/browse_business/remove_saved_business_controller.dart';
import 'package:loci/presentation/controllers/qr_code/get_my_qr_controller.dart';
import 'package:loci/presentation/controllers/recent_activity/recent_activity_controller.dart';
import 'package:loci/presentation/controllers/subscription/plans_controller.dart';

class DrawerBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut(()=>GetMyQrCodeController());
    Get.lazyPut(()=>RecentActivityController());
    Get.lazyPut(()=>PlansController());
    Get.lazyPut(()=>RemoveSavedBusinessController());

  }
}
