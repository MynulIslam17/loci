import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
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
        final index = incoming.meetings.indexWhere((m) => m.id == meetingId);
        final merged = index >= 0
            ? updated.mergeWith(incoming.meetings[index])
            : updated;
        incoming.replaceMeeting(merged);
      } else {
        await incoming.fetchIncomingMeetings();
      }
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _loadingMap[meetingId] = null;
    }
  }
}
