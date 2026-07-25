import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/incoming_meetings_controller.dart';
import 'package:loci/features/network/presentation/controllers/respond_meeting_controller.dart';
import 'package:loci/features/network/presentation/controllers/schedule_meeting_controller.dart';
import 'package:loci/features/network/presentation/controllers/sent_meetings_controller.dart';

class MeetingsBindings extends Bindings {
  @override
  void dependencies() {
    final service = Get.find<NetworkService>();
    Get.lazyPut(() => SentMeetingsController(service), fenix: true);
    Get.lazyPut(() => IncomingMeetingsController(service), fenix: true);
    Get.lazyPut(() => RespondMeetingController(service), fenix: true);
    Get.lazyPut(() => ScheduleMeetingController(service), fenix: true);
  }
}
