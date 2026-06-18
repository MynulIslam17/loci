import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';


class SendNewReferralsController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> sendReferral({
    required String recipientEmail,
    required String recipientName,
    required String recipientCompany,
    required String businessOwnerEmail,
    required String businessOwnerName,
    required String ownerCompanyName,
    String? message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    final response = await Get.find<NetworkCaller>().postRequest(
      url: AppUrl.sendReferral,
      body: {
        'recipientEmail': recipientEmail,
        'recipientName': recipientName,
        'recipientCompany': recipientCompany,
        'businessOwnerEmail': businessOwnerEmail,
        'businessOwnerName': businessOwnerName,
        'businessOwnerCompany': ownerCompanyName,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );

    _isLoading = false;

    if (!response.isSuccess) {
      _errorMessage = response.body?['message'] ?? 'Failed to send referral';
      update();
      return false;
    }

    update();
    return true;
  }
}
