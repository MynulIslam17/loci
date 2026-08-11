import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class PollQuestionController extends GetxController {
  PollQuestionController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<bool> createPollQuestion({
    required String communityId,
    required String pollQuestion,
    required String pollCategory,
    required String qType,
    String? businessId,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _service.createPollQuestion(
        communityId: communityId,
        pollQuestion: pollQuestion,
        pollCategory: pollCategory,
        qType: qType,
        businessId: businessId,
      );
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
