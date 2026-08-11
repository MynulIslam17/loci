import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';

/// UI → [JoinCommunityController] → [CommunityService] → repository → API.
class JoinCommunityController extends GetxController {
  JoinCommunityController(this._service);

  final CommunityService _service;

  final joiningId = RxnString();
  final errorMessage = RxnString();
  final successMessage = RxnString();

  bool isJoining(String id) => joiningId.value == id;

  Future<bool> joinCommunity({required String joinId}) async {
    joiningId.value = joinId;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.joinCommunity(qrCode: joinId);
      if (Get.isRegistered<AllCommunityController>()) {
        await Get.find<AllCommunityController>().refreshCommunities();
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      joiningId.value = null;
    }
  }
}
