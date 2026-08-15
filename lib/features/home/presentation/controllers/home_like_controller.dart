import 'package:get/get.dart';
import 'package:loci/core/utils/offline_like.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/home/presentation/controllers/question_list_controller.dart';

class HomeLikeController extends GetxController {
  HomeLikeController(this._service);

  final HomeService _service;

  Future<void> toggleLike(String questionId) async {
    final listCtrl = Get.find<QuestionListController>();

    listCtrl.toggleLikeLocally(questionId);

    if (await OfflineLike.revertIfOffline(
      () => listCtrl.toggleLikeLocally(questionId),
    )) {
      return;
    }

    try {
      await _service.toggleLike(questionId: questionId);
    } catch (e) {
      listCtrl.toggleLikeLocally(questionId);
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
