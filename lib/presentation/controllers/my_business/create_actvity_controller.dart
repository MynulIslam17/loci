import 'dart:io';
import 'package:get/get.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';

class CreateActivityController extends GetxController {


  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  /// -------------------------------
  /// LOADER METHOD
  /// -------------------------------
  void setLoading(bool value) {
    isLoading = value;
    update();
  }

  /// -------------------------------
  /// CREATE ACTIVITY API (MULTIPART)
  /// -------------------------------
  Future<void> createActivity({
    required String url,
    required Map<String, String> body,
    Map<String, File>? files,
  }) async {
    try {
      setLoading(true);

      final response = await Get.find<NetworkCaller>().multipartRequest(url: url,
        method: "POST",
        fields: body,
        files: files


      );


      if (response.isSuccess) {
        successMessage = response.body?['message'] ?? "created successfully";
        errorMessage = null;

        SnackbarService.success(successMessage!);

        Get.back();
      } else {
        errorMessage = response.errorMessage ?? "Failed to create activity";
        successMessage = null;

        SnackbarService.error(errorMessage!);
      }
    } catch (e) {
      errorMessage = e.toString();
      successMessage = null;

      SnackbarService.error("Something went wrong: $e");
    } finally {
      setLoading(false);
    }
  }
}