import 'package:get/get.dart';
import 'package:loci/features/event/domain/services/event_service.dart';

class RSVPController extends GetxController {
  RSVPController(this._service);

  final EventService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<String> _successMessage = Rxn<String>();
  final Rxn<String> _loadingEventId = Rxn<String>();

  String? get errorMessage => _errorMessage.value;
  String? get successMessage => _successMessage.value;
  bool get isLoading => _isLoading.value;
  String? get loadingEventId => _loadingEventId.value;

  /// ---- Send RSVP ----
  Future<bool> sendRSVP({
    required String eventId,
    required String status,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;
      _successMessage.value = null;
      _loadingEventId.value = eventId;

      _successMessage.value = await _service.sendRsvp(
        eventId: eventId,
        status: status,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
      _loadingEventId.value = null;
    }
  }
}
