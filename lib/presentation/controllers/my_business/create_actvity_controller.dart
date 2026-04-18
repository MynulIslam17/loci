import 'dart:io';
import 'package:get/get.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class CreateActivityController extends GetxController {
  bool isLoading = false;

  String message = "";

  void setLoading(bool value) {
    isLoading = value;
    update();
  }

  Future<bool> createActivity({
    required String url,
    required Map<String, String> body,
    Map<String, File>? files,
  }) async {
    try {
      setLoading(true);

      final NetworkResponse response =
      await Get.find<NetworkCaller>().multipartRequest(
        url: url,
        method: "POST",
        fields: body,
        files: files,
      );

      if (response.isSuccess) {
        message = response.body?['message'] ?? "Created successfully";
        update();
        return true;
      }else {
        message = response.body?["errors"]?["details"]?[0]
            ?? response.body?["message"]
            ?? "Failed to create activity";

        update();
        return false;
      }
    } catch (e) {
      message = e.toString();
      update();
      return false;
    } finally {
      setLoading(false);
    }
  }
}