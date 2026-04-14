

import 'package:get/get.dart';

import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';




class PatchController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Generic Post Method for any data size
  /// [url] - The API endpoint
  /// [body] - The Map of data you want to send
  Future<bool> patchData({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update(); // Notify UI to show loading

    try {
      // Using your existing NetworkCaller logic
      NetworkResponse response = await Get.find<NetworkCaller>().patchRequest(
        url: url,
        body: body,
      );

      if (response.isSuccess) {
        _isLoading = false;
        update();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Submission failed";
        _isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
      _isLoading = false;
      update();
      return false;
    }
  }
}