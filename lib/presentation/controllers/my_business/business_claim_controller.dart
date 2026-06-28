import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

import '../../../data/models/busniess/business_claim_request_model.dart';
import '../../../data/models/busniess/create_business_request_model.dart';
import '../../../data/models/busniess/create_business_response_model.dart';

class BusinessClaimController extends GetxController {
  final NetworkCaller _networkCaller = Get.find<NetworkCaller>();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<CreatedBusinessModel?> createBusiness(
    CreateBusinessRequestModel request, {
    List<File> attachments = const [],
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _networkCaller.multipartRequest(
        url: AppUrl.createBusiness,
        fields: request.toFields(),
        multiFiles: attachments.isEmpty
            ? null
            : request.attachmentsMultiFileMap(attachments),
      );

      if (response.isSuccess && response.body != null) {
        final result = CreateBusinessResponseModel.fromJson(response.body!);

        if (result.data != null && result.data!.id.isNotEmpty) {
          _successMessage = result.message.isNotEmpty
              ? result.message
              : 'Business created';
          update();
          return result.data;
        }

        _errorMessage = 'Business created but no id returned';
        update();
        return null;
      }

      _errorMessage = _parseErrorMessage(response.body) ??
          response.errorMessage ??
          'Failed to create business';
      update();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      update();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> claimBusiness(BusinessClaimRequestModel request) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _networkCaller.multipartRequest(
        url: AppUrl.claimBusiness,
        fields: request.toFields(),
        multiFiles: request.toMultiFileMap(),
      );

      if (response.isSuccess && response.body != null) {
        _successMessage = response.body?['message'] ?? 'Claim submitted';
        update();
        return true;
      }

      _errorMessage = _parseErrorMessage(response.body) ??
          response.errorMessage ??
          'Failed to submit claim';
      update();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      update();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }

  String? _parseErrorMessage(Map<String, dynamic>? body) {
    if (body == null) return null;

    final errors = body['errors'];
    if (errors is Map<String, dynamic>) {
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value != null) return value.toString();
      }
    }

    return body['message'] as String?;
  }
}
