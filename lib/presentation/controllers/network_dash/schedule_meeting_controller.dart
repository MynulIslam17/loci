import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

class ScheduleMeetingController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> scheduleMeeting({
    required String recipientName,
    required String recipientEmail,
    required String meetingDate,
    required String meetingTime,
    required String location,
    String? message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.scheduleMeeting,
        body: {
          'recipient': {
            'name': recipientName,
            'email': recipientEmail,
          },
          'meetingDate': meetingDate,
          'meetingTime': meetingTime,
          'location': location,
          if (message != null && message.isNotEmpty) 'message': message,
        },
      );

      if (!response.isSuccess) {
        _errorMessage = response.body?['message'] ?? 'Failed to schedule meeting';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }
}
