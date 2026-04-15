import 'package:get/get.dart';
import 'package:loci/presentation/controllers/my_business/create_actvity_controller.dart';
import 'package:loci/presentation/controllers/my_business/get_my_business_list _controller.dart';

import '../controllers/my_business/my_business_profile_controller.dart';

class MyBusinessBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>GetMyBusinessController());
    Get.lazyPut(()=>CreateActivityController());
    Get.lazyPut(()=>MyBusinessProfileController());


  }

}