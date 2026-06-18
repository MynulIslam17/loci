import 'package:get/get.dart';
import 'package:loci/presentation/controllers/network_dash/incoming_meetings_controller.dart';
import 'package:loci/presentation/controllers/network_dash/respond_meeting_controller.dart';
import 'package:loci/presentation/controllers/network_dash/schedule_meeting_controller.dart';
import 'package:loci/presentation/controllers/network_dash/sent_meetings_controller.dart';

class MeetingsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SentMeetingsController(), fenix: true);
    Get.lazyPut(() => IncomingMeetingsController(), fenix: true);
    Get.lazyPut(() => RespondMeetingController(), fenix: true);
    Get.lazyPut(() => ScheduleMeetingController(), fenix: true);
  }
}
