import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class RemoveMemberController extends GetxController {
  RemoveMemberController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<bool> removeMember({
    required String communityId,
    required String memberId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await _service.removeMember(
        communityId: communityId,
        memberId: memberId,
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
