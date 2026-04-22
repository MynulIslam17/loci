import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

import '../../../data/models/busniess/business_claim_request_model.dart';

class BusinessClaimController extends GetxController {
  final NetworkCaller _networkCaller = Get.find<NetworkCaller>();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ==============================
  // API CALL ONLY
  // ==============================
  Future<bool> claimBusiness(BusinessClaimRequestModel request) async {
    try {
      _setLoading(true);

      final response = await _networkCaller.multipartRequest(
        url: AppUrl.createBusiness,
        fields: request.toFields().isNotEmpty ?  request.toFields() : null,
        files: request.toFileMap(),
        multiFiles: request.toMultiFileMap()
      );

      _setLoading(false);

      if (response.isSuccess && response.body != null) {
        _successMessage = response.body?['message'] ?? "Success";
        _errorMessage = null;
        update();
        return true;
      }

      _errorMessage = response.errorMessage;
      _successMessage = null;
      update();
      return false;
    } catch (e) {
      _setLoading(false);

      _errorMessage = e.toString();
      _successMessage = null;
      update();

      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }
}