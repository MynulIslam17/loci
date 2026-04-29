import 'package:get/get.dart';
import 'package:loci/presentation/controllers/browse_business/browse_business_controller.dart';

class BrowseBusinessBindings extends Bindings{
  @override
  void dependencies() {

    Get.lazyPut(()=>BrowseBusinessController());


  }

}