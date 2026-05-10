import 'dart:io';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Reusable controller for all 4 announcement types:
///
///   notice   — fields: type, communityId, details
///   activity — fields: type, communityId, activityRefType, activityId
///   offer    — fields: type, communityId, details  +  image file
///   question — fields: type, communityId, details
///
/// Automatically uses multipart when [image] is supplied, JSON otherwise.
class CreateAnnouncementController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createAnnouncement({
    required Map<String, String> fields,
    File? image,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final caller = Get.find<NetworkCaller>();

      if (image != null) {
        final response = await caller.multipartRequest(
          url: AppUrl.crateAnnouncement,
          method: 'POST',
          fields: fields,
          files: {'image': image},
        );
        if (!response.isSuccess) {
          _errorMessage = response.errorMessage ?? 'Failed to create announcement';
          return false;
        }
      } else {
        final response = await caller.postRequest(
          url: AppUrl.crateAnnouncement,
          body: fields,
        );
        if (!response.isSuccess) {
          _errorMessage = response.errorMessage ?? 'Failed to create announcement';
          return false;
        }
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    update();
  }
}
