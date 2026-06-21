import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

class CreateAdController extends GetxController {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> submitAd({
    required String title,
    required String businessName,
    required String location,
    required DateTime runtimeDate,
    required File image,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().multipartRequest(
        url: AppUrl.submitAd,
        method: 'POST',
        fields: {
          'title': title,
          'businessName': businessName,
          'location': location,
          'runtimeDate': runtimeDate.toUtc().toIso8601String(),
        },
        files: {'image': image},
      );

      if (!response.isSuccess || response.body == null) {
        errorMessage = response.errorMessage ?? 'Failed to submit ad';
        return false;
      }

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
}
