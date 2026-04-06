import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_response.dart';
import '../../../core/network/network_caller.dart';

class RSVPController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _loadingEventId;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _isLoading;
  String? get loadingEventId => _loadingEventId;

  /// ---- Send RSVP ----
  Future<bool> sendRSVP({
    required String eventId,
    required String status,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _loadingEventId = eventId;
      update();

      final NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.rsvpEvent(eventId),
        body: {
          "status": status,
        },
      );

      if (response.body != null && response.isSuccess) {
        _successMessage = response.body?['message'] ?? "RSVP sent successfully";
        return true;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _loadingEventId=null;
      update();
    }
  }
}