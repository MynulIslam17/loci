import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

class RemoveMemberController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> removeMember({
    required String communityId,
    required String memberId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().deleteRequest(
        url: AppUrl.removeCommunityMember(communityId, memberId),
      );

      if (response.isSuccess) {
        return true;
      } else {
        _errorMessage = response.body?['message'] ?? 'Failed to remove member';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }
}
