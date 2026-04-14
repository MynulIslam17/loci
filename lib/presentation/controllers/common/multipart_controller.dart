import 'dart:io';
import 'package:get/get.dart';

import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';




class ReusableMultipartController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    update();
  }

  /// A Dynamic Multipart Method
  /// [url] - The API endpoint
  /// [fields] - A map of all text data (title, description, etc.)
  /// [files] - A map of all files with their respective API keys
  /// [method] - 'POST' or 'PATCH'
  Future<bool> sendMultipartRequest({
    required String url,
    required Map<String, String> fields,
    Map<String, File>? files,
    String method = 'POST',
  }) async {
    bool isSuccess = false;
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      // Send the request using the provided maps
      NetworkResponse response = await Get.find<NetworkCaller>().multipartRequest(
        url: url,
        method: method,
        fields: fields,
        files: files,
      );

      if (response.isSuccess) {
        isSuccess = true;
      } else {
        _errorMessage = response.errorMessage ?? "Request failed";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    } finally {
      _isLoading = false;
      update();
    }

    return isSuccess;
  }
}