import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/meeting/meeting_models.dart';
import 'package:loci/presentation/controllers/network_dash/incoming_meetings_controller.dart';

class RespondMeetingController extends GetxController {
  static const String confirmAction = 'confirm';
  static const String rejectAction = 'reject';

  final Map<String, String?> _loadingMap = {};

  bool isConfirming(String meetingId) =>
      _loadingMap[meetingId] == confirmAction;
  bool isRejecting(String meetingId) => _loadingMap[meetingId] == rejectAction;
  bool isResponding(String meetingId) => _loadingMap[meetingId] != null;

  Future<void> respond(String meetingId, String action) async {
    _loadingMap[meetingId] = action;
    update();

    final NetworkResponse response =
        await Get.find<NetworkCaller>().patchRequest(
      url: AppUrl.respondMeeting(meetingId),
      body: {'action': action},
    );

    _loadingMap[meetingId] = null;
    update();

    if (response.isSuccess) {
      if (!Get.isRegistered<IncomingMeetingsController>()) return;
      final incoming = Get.find<IncomingMeetingsController>();

      try {
        final data = response.body?['data'];
        if (data is Map<String, dynamic>) {
          final updated = IncomingMeetingModel.fromJson(data);
          incoming.replaceMeeting(updated);
          return;
        }
      } catch (_) {
        // fall through to a full refresh if parsing the inline update fails
      }
      await incoming.fetchIncomingMeetings();
    } else {
      Get.snackbar(
        'Error',
        response.errorMessage ?? 'Something went wrong.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
