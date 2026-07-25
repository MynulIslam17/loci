import 'package:get/get.dart';
import 'package:loci/features/community/data/models/announcement_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class PostPollOptionController extends GetxController {
  PostPollOptionController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<AnnouncementModel?> addPollOption({
    required String announcementId,
    required String question,
    String? imageUrl,
  }) async {
    if (question.trim().isEmpty) return null;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      return await _service.addPollOption(
        announcementId: announcementId,
        text: question.trim(),
        imageUrl: imageUrl,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    isLoading.value = false;
    errorMessage.value = null;
  }
}
