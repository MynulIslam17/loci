import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/business_claim_request_model.dart';
import 'package:loci/features/my_business/data/models/create_business_request_model.dart';
import 'package:loci/features/my_business/data/models/create_business_response_model.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class BusinessClaimController extends GetxController {
  BusinessClaimController(this._service);

  final MyBusinessService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  Future<CreatedBusinessModel?> createBusiness(
    CreateBusinessRequestModel request, {
    List<File> attachments = const [],
  }) async {
    try {
      _setLoading(true);
      errorMessage.value = null;

      final result = await _service.createBusiness(
        request,
        attachments: attachments,
      );
      successMessage.value = result.message;
      return result.business;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> claimBusiness(BusinessClaimRequestModel request) async {
    try {
      _setLoading(true);
      errorMessage.value = null;

      successMessage.value = await _service.claimBusiness(request);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading.value = value;
  }
}
