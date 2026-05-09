import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class VoteController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // -------------------------------------------------
  // SUBMIT VOTE
  // -------------------------------------------------
  Future<bool> submitVote({
    required String announcementId,
    required String optionId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      update();

      final NetworkResponse response =
          await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.voteOnAnnouncementPoll(announcementId),
        body: {
          "optionIds": [optionId],
        },
      );

      if (response.isSuccess && response.body != null) {
        _successMessage = response.body?['message'] ?? "Vote submitted successfully";
        return true;
      } else {
        _errorMessage = response.body?['message'] ?? "Failed to submit vote";
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
