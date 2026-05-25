import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

class HomeVoteController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> submitVote({
    required String questionId,
    required String optionId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.homeVoteOnPollOption(questionId),
        body: {'optionId': optionId},
      );

      if (response.isSuccess && response.body != null) {
        _successMessage =
            response.body?['message'] ?? 'Vote recorded';
        return true;
      } else {
        _errorMessage =
            response.body?['message'] ?? 'Failed to submit vote';
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
