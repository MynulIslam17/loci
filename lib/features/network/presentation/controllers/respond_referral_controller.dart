import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/received_referrals_controller.dart';

class RespondReferralController extends GetxController {
  RespondReferralController(this._service);

  final NetworkService _service;

  final RxMap<String, String?> _loadingMap = <String, String?>{}.obs;

  bool isAccepting(String referralId) => _loadingMap[referralId] == 'accept';
  bool isRejecting(String referralId) => _loadingMap[referralId] == 'reject';
  bool isResponding(String referralId) => _loadingMap[referralId] != null;

  Future<void> respond(String referralId, String action) async {
    _loadingMap[referralId] = action;

    try {
      final updated = await _service.respondReferral(
        referralId: referralId,
        action: action,
      );

      if (updated != null && Get.isRegistered<ReceivedReferralsController>()) {
        Get.find<ReceivedReferralsController>().replaceReferral(updated);
      }
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _loadingMap[referralId] = null;
    }
  }
}
