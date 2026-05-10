import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/presentation/controllers/community/announcement_controller.dart';

class AnnouncementLikeController extends GetxController {
  Future<void> toggleLike(String announcementId) async {
    final announcementCtrl = Get.find<AnnouncementController>();

    // Optimistic update
    announcementCtrl.toggleLikeLocally(announcementId);

    try {
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.announcementLike(announcementId),
        body: {},
      );

      if (!response.isSuccess) {
        // Revert on failure
        announcementCtrl.toggleLikeLocally(announcementId);
       SnackbarService.error(response.body?['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      // Revert on error
      announcementCtrl.toggleLikeLocally(announcementId);
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
