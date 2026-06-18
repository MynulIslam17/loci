import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/referral/referral_response_model.dart';
import 'package:loci/presentation/controllers/network_dash/received_referrals_controller.dart';

class RespondReferralController extends GetxController {
  final Map<String, String?> _loadingMap = {};

  bool isAccepting(String referralId) => _loadingMap[referralId] == 'accept';
  bool isRejecting(String referralId) => _loadingMap[referralId] == 'reject';
  bool isResponding(String referralId) => _loadingMap[referralId] != null;

  Future<void> respond(String referralId, String action) async {
    _loadingMap[referralId] = action;
    update();

    final NetworkResponse response = await Get.find<NetworkCaller>().patchRequest(
      url: AppUrl.acceptReferral(referralId),
      body: {'action': action},
    );

    _loadingMap[referralId] = null;
    update();

    if (response.isSuccess && response.body?['data'] != null) {
      final updated = ReferralModel.fromJson(response.body!['data']);
      final receivedController = Get.find<ReceivedReferralsController>();
      final index = receivedController.referrals.indexWhere((r) => r.id == referralId);
      if (index != -1) {
        receivedController.referrals[index] = updated;
        receivedController.update();
      }
    } else if (!response.isSuccess) {
      Get.snackbar(
        'Error',
        response.errorMessage ?? 'Something went wrong.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
