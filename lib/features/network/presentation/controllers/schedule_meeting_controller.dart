import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

class ScheduleMeetingController extends GetxController {
  ScheduleMeetingController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  Future<bool> scheduleMeeting({
    required String recipientName,
    required String recipientEmail,
    required String meetingDate,
    required String meetingTime,
    required String location,
    String? message,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      await _service.scheduleMeeting(
        recipientName: recipientName,
        recipientEmail: recipientEmail,
        meetingDate: meetingDate,
        meetingTime: meetingTime,
        location: location,
        message: message,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
