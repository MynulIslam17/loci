import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

class CreateAdController extends GetxController {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> submitAd({
    required String title,
    required DateTime endDate,
    required File image,
    String? businessName,
    String? location,
    DateTime? startDate,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      update();

      final fields = <String, String>{
        'title': title,
        'endDate': endDate.toUtc().toIso8601String(),
      };

      if (businessName != null && businessName.isNotEmpty) {
        fields['businessName'] = businessName;
      }
      if (location != null && location.isNotEmpty) {
        fields['location'] = location;
      }
      if (startDate != null) {
        fields['startDate'] = startDate.toUtc().toIso8601String();
      }

      final response = await Get.find<NetworkCaller>().multipartRequest(
        url: AppUrl.submitAd,
        method: 'POST',
        fields: fields,
        files: {'image': image},
      );

      if (!response.isSuccess || response.body == null) {
        errorMessage = response.errorMessage ?? 'Failed to submit ad';
        return false;
      }

      successMessage = response.body!['message'] as String? ??
          'Ad submitted for review';
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
