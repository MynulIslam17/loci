import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

class PollQuestionController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createPollQuestion({
    required String communityId,
    required String pollQuestion,
    required String pollCategory,
    required String qType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.crateAnnouncement,
        body: {
          'type': 'question',
          'communityId': communityId,
          'pollQuestion': pollQuestion,
          'pollCategory': pollCategory,
          'qtype': qType,
        },
      );

      if (!response.isSuccess) {
        _errorMessage = response.errorMessage ?? 'Failed to create poll question';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    update();
  }
}
