import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';

class JoinCommunityController extends GetxController {
  JoinCommunityController(this._service);

  final CommunityService _service;

  final joiningId = RxnString();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final successMessage = RxnString();

  ///  per-item loading
  bool isJoining(String id) => joiningId.value == id;

  Future<bool> joinCommunity({required String joinId}) async {
    joiningId.value = joinId;

    errorMessage.value = null;
    successMessage.value = null;

    try {
      successMessage.value = await _service.joinCommunity(qrCode: joinId);
      SnackbarService.success(successMessage.value!);
      Get.find<AllCommunityController>().refreshCommunities();
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      SnackbarService.error(errorMessage.value!);
      return false;
    } finally {
      joiningId.value = null;
    }
  }
}
