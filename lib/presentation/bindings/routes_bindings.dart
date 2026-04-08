import 'package:get/get.dart';
import 'package:loci/presentation/controllers/routes/route_details_controller.dart';



class RoutesBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

   Get.lazyPut(()=>RouteDetailsController());
  }

}