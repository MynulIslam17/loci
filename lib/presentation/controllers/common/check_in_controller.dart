import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class CheckInController extends GetxController {

  // =========================
  // State Variables
  // =========================
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // =========================
  // Getters
  // =========================
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// =========================
  /// Check-In API Call
  /// =========================
  Future<bool> doCheckIn({
    required String checkInCode,
    String? name,
    String? email,
    String? avatar,

  }) async {
    try {
      // start loading
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      update();

      // =========================
      // Build request body safely
      // =========================
      final Map<String, dynamic> body = {
        "qrPayload": checkInCode,
      };

      // Add leadData only if at least one field exists
      if (name != null || email != null || avatar != null ) {
        body["leadData"] = {
          if (name != null) "name": name,
          if (email != null) "email": email,
          if (avatar != null) "avatar": avatar,

        };
      }

      final NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.checkIn,
        body: body,
      );

      // =========================
      // Success Response
      // =========================
      if (response.isSuccess && response.body != null) {
        _successMessage =
            response.body?['message'] ?? "Check-in successful";
        return true;
      }

      // =========================
      // Failure Response
      // =========================
      _errorMessage = response.body?['message'] ?? "Check-in failed";
      return false;

    } catch (e) {
      _errorMessage = e.toString();
      return false;

    } finally {
      _isLoading = false;
      update();
    }
  }
}