import 'package:get/get.dart';

import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';

class PostController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String ? _token;

  String ? get getToken=>_token;

  /// Generic Post Method for any data size
  /// [url] - The API endpoint
  /// [body] - The Map of data you want to send
  Future<bool> postData({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update(); // Notify UI to show loading

    try {
      // Using your existing NetworkCaller logic
      NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: url,
        body: body,
      );

      if (response.body != null && response.isSuccess) {
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



  /// this method will use when needs temp token like(reset ,forget,verify email screen)

  Future<bool> postWithTempToken({
    required String url,
    required Map<String, dynamic> body,
    String? tempToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      // Use the passed tempToken, but if it's null,
      // fall back to the one we already have saved in _token
      String? tokenToSend = tempToken ?? _token;

      NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: url,
        body: body,
        overrideToken: tokenToSend,
      );

      if (response.body != null && response.isSuccess) {
        // Only update _token if the API actually returns raffles new one
        if (response.body!["data"] != null && response.body!["data"]["token"] != null) {
          _token = response.body!["data"]["token"];
        }

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
