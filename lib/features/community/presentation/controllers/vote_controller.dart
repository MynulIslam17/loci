import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class VoteController extends GetxController {
  VoteController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  // -------------------------------------------------
  // SUBMIT VOTE
  // -------------------------------------------------
  Future<bool> submitVote({
    required String announcementId,
    required String optionId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      successMessage.value = null;

      successMessage.value = await _service.submitVote(
        announcementId: announcementId,
        optionId: optionId,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
