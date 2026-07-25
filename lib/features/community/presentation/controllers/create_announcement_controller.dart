import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

/// Reusable controller for all 4 announcement types:
///
///   notice   — fields: type, communityId, details
///   activity — fields: type, communityId, activityRefType, activityId
///   offer    — fields: type, communityId, details  +  image file
///
/// Automatically uses multipart when [image] is supplied, JSON otherwise.
class CreateAnnouncementController extends GetxController {
  CreateAnnouncementController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<bool> createAnnouncement({
    required Map<String, String> fields,
    File? image,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _service.createAnnouncement(fields: fields, image: image);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    isLoading.value = false;
    errorMessage.value = null;
  }
}
