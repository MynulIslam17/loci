import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/presentation/controllers/comment/announcement_controller.dart';

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
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Failed to like',
          snackPosition: SnackPosition.BOTTOM,
        );
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
