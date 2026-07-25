import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/home/presentation/controllers/question_list_controller.dart';

class HomeLikeController extends GetxController {
  HomeLikeController(this._service);

  final HomeService _service;

  Future<void> toggleLike(String questionId) async {
    final listCtrl = Get.find<QuestionListController>();

    // Optimistic update — flip immediately
    listCtrl.toggleLikeLocally(questionId);

    try {
      await _service.toggleLike(questionId: questionId);
    } catch (e) {
      // Revert on failure
      listCtrl.toggleLikeLocally(questionId);
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
