import 'package:get/get.dart';
import 'package:loci/features/event/domain/services/event_service.dart';
import 'package:loci/features/event/presentation/controllers/event_details_controller.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<EventService>();
    Get.lazyPut(() => EventDetailsController(service));
  }
}

/// Backward-compatible alias for route bindings.
typedef EventBindings = EventBinding;
