import 'package:get/get.dart';
import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/features/event/data/models/event_detail_model.dart';
import 'package:loci/features/event/domain/services/event_service.dart';

class EventDetailsController extends GetxController {
  EventDetailsController(this._service);

  final EventService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<EventDetailsModel> _eventDetails = Rxn<EventDetailsModel>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  EventDetailsModel? get eventDetails => _eventDetails.value;

  /// Fetch event details by event ID
  Future<void> fetchEventDetails(String eventId) async {
    _isLoading.value = true;
    _errorMessage.value = null;
    _eventDetails.value = null;

    try {
      _eventDetails.value = await _service.getEventDetails(eventId);
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  /// update rsvp status and count locally
  void updateRsvpStatus(RsvpStatus status) {
    final current = _eventDetails.value;
    if (current == null) return;

    _eventDetails.value = current.copyWith(
      eventModel: current.eventModel.copyWith(
        myRsvpStatus: status,
        goingCount: status == RsvpStatus.going
            ? current.eventModel.goingCount + 1
            : current.eventModel.goingCount,
      ),
    );
  }

  /// update check-in status locally.
  /// When [onlyIfId] is set, updates only if it matches the open event.
  void updateCheckInStatus(
    CheckInStatus status, {
    String? onlyIfId,
  }) {
    final current = _eventDetails.value;
    if (current == null) return;
    if (onlyIfId != null &&
        onlyIfId.isNotEmpty &&
        current.eventModel.id != onlyIfId) {
      return;
    }

    _eventDetails.value = current.copyWith(myCheckInStatus: status);
    _eventDetails.refresh();
  }
}
