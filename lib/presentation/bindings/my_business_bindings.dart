import 'package:get/get.dart';
import 'package:loci/presentation/controllers/my_business/get_my_business_controller.dart';

class MyBusinessBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>GetMyBusinessController());


  }

}