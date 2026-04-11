import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class ManualCheckInController extends GetxController {

  // -------------------------
  // State
  // -------------------------
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // -------------------------
  // Getters
  // -------------------------
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // -------------------------
  // Manual Check-In API Call
  // -------------------------
  Future<bool> doManualCheckIn({
    required String checkInCode,
    String? name,
    String? email,
    String? avatar,
  }) async {

    try {
      // 🔹 Start loading
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      update();

      // 🔹 Request body
      Map<String, dynamic> body = {
        "checkInCode": checkInCode,
      };

      // 🔹 Add leadData ONLY if any value exists
      if (name != null || email != null || avatar != null) {
        body["leadData"] = {
          if (name != null) "name": name,
          if (email != null) "email": email,
          if (avatar != null) "avatar": avatar,
        };
      }

      // 🔹 API Call
      final NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.eventManualCheckIn(checkInCode),
        body: body,
      );

      // 🔹 Success
      if (response.isSuccess && response.body != null) {
        _successMessage =
            response.body?['message'] ?? "Check-in successful";
        return true;
      }

      // 🔹 Failed response
      _errorMessage =
          response.body?['message'] ?? "Check-in failed";
      return false;

    } catch (e) {
      // 🔹 Exception
      _errorMessage = e.toString();
      return false;

    } finally {
      // 🔹 Stop loading
      _isLoading = false;
      update();
    }
  }
}