import 'package:get/get.dart';
import 'package:loci/features/home/domain/services/home_service.dart';

class HomeVoteController extends GetxController {
  HomeVoteController(this._service);

  final HomeService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  Future<bool> submitVote({
    required String questionId,
    required String optionId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      successMessage.value = null;

      successMessage.value = await _service.submitVote(
        questionId: questionId,
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
