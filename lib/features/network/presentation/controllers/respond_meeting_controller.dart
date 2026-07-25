import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/incoming_meetings_controller.dart';

class RespondMeetingController extends GetxController {
  RespondMeetingController(this._service);

  final NetworkService _service;

  static const String confirmAction = 'confirm';
  static const String rejectAction = 'reject';

  final RxMap<String, String?> _loadingMap = <String, String?>{}.obs;

  bool isConfirming(String meetingId) =>
      _loadingMap[meetingId] == confirmAction;
  bool isRejecting(String meetingId) => _loadingMap[meetingId] == rejectAction;
  bool isResponding(String meetingId) => _loadingMap[meetingId] != null;

  Future<void> respond(String meetingId, String action) async {
    _loadingMap[meetingId] = action;

    try {
      final updated = await _service.respondMeeting(
        meetingId: meetingId,
        action: action,
      );

      if (!Get.isRegistered<IncomingMeetingsController>()) return;
      final incoming = Get.find<IncomingMeetingsController>();

      if (updated != null) {
        incoming.replaceMeeting(updated);
      } else {
        await incoming.fetchIncomingMeetings();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _loadingMap[meetingId] = null;
    }
  }
}
