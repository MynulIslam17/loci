import 'package:get/get.dart';
import 'package:loci/core/utils/offline_like.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';

class AnnouncementLikeController extends GetxController {
  AnnouncementLikeController(this._service);

  final CommunityService _service;

  Future<void> toggleLike(String announcementId) async {
    final announcementCtrl = Get.find<AnnouncementController>();

    announcementCtrl.toggleLikeLocally(announcementId);

    if (await OfflineLike.revertIfOffline(
      () => announcementCtrl.toggleLikeLocally(announcementId),
    )) {
      return;
    }

    try {
      await _service.toggleAnnouncementLike(announcementId);
    } catch (e) {
      announcementCtrl.toggleLikeLocally(announcementId);
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
