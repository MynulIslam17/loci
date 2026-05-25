import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/presentation/controllers/home/question_list_controller.dart';

class HomeLikeController extends GetxController {
  Future<void> toggleLike(String questionId) async {
    final listCtrl = Get.find<QuestionListController>();

    // Optimistic update — flip immediately
    listCtrl.toggleLikeLocally(questionId);

    try {
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.homeFeedPostLike(questionId),
        body: {},
      );

      if (!response.isSuccess) {
        // Revert on failure
        listCtrl.toggleLikeLocally(questionId);
        SnackbarService.error(
          response.body?['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      // Revert on error
      listCtrl.toggleLikeLocally(questionId);
      SnackbarService.error('Something went wrong');
    }
  }
}
