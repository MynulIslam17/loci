import 'package:get/get.dart';
import 'package:loci/presentation/controllers/event/event_details_controller.dart';
import 'package:loci/presentation/controllers/event/rsvp_controller.dart';

class EventBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies


       Get.lazyPut(()=>EventDetailsController());

  }

}