import 'dart:io';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

class PostPollOptionController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Posts a poll option to an announcement.
  /// [text] must be non-empty (business name selected from search).
  /// [image] is optional.
  /// Returns false without calling the API if [text] is blank.
  Future<bool> addPollOption({
    required String announcementId,
    required String text,
    File? image,
  }) async {
    if (text.trim().isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final caller = Get.find<NetworkCaller>();
      final fields = {'text': text.trim()};

      if (image != null) {
        final response = await caller.multipartRequest(
          url: AppUrl.addPollOption(announcementId),
          method: 'POST',
          fields: fields,
          files: {'image': image},
        );
        if (!response.isSuccess) {
          _errorMessage = response.errorMessage ?? 'Failed to add poll option';
          return false;
        }
      } else {
        final response = await caller.postRequest(
          url: AppUrl.addPollOption(announcementId),
          body: fields,
        );
        if (!response.isSuccess) {
          _errorMessage = response.errorMessage ?? 'Failed to add poll option';
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
