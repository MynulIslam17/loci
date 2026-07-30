import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/sent_referrals_controller.dart';

class SendNewReferralsController extends GetxController {
  SendNewReferralsController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  Future<bool> sendReferral({
    required String recipientEmail,
    required String recipientName,
    required String businessOwnerEmail,
    required String businessOwnerName,
    String? recipientCompany,
    String? ownerCompanyName,
    String? message,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      await _service.sendReferral(
        recipientEmail: recipientEmail,
        recipientName: recipientName,
        recipientCompany: recipientCompany,
        businessOwnerEmail: businessOwnerEmail,
        businessOwnerName: businessOwnerName,
        ownerCompanyName: ownerCompanyName,
        message: message,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> onSendSuccess() async {
    if (!Get.isRegistered<SentReferralsController>()) return;
    await Get.find<SentReferralsController>().fetchSentReferrals();
  }
}
