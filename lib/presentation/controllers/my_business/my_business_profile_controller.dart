import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../data/models/busniess/business_profile_model.dart';

class MyBusinessProfileController extends GetxController {
  bool isLoading = false;

  String? _errorMessage;
  BusinessModel? business;

  String? get errorMessage => _errorMessage;

  /// =========================
  /// SET LOADING
  /// =========================
  void setLoading(bool value) {
    isLoading = value;
    update();
  }

  /// =========================
  /// FETCH BUSINESS PROFILE
  /// =========================
  Future<bool> fetchBusinessProfile(
      String businessId, {
        bool isRefresh = false,
      }) async {
    try {
      if (!isRefresh) {
        setLoading(true);
      }

      _errorMessage = null;

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.businessProfile(businessId),
      );

      if (response.isSuccess && response.body != null) {
        business = BusinessModel.fromJson(response.body!['data']);
        return true;
      } else {
        _errorMessage =
            response.errorMessage ?? "Failed to load business profile";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      if (!isRefresh) {
        setLoading(false);
      }
      update();
    }
  }

  /// =========================
  /// REFRESH SHORTCUT (OPTIONAL BUT CLEAN)
  /// =========================
  Future<void> refreshBusinessProfile(String businessId) async {
    await fetchBusinessProfile(businessId, isRefresh: true);
  }


  /// =========================
  /// UPDATE BUSINESS TEXT DATA
  /// =========================
  Future<bool> updateBusinessData({
    required String businessId,
    required Map<String, dynamic> body,
  }) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final NetworkResponse response = await Get.find<NetworkCaller>().patchRequest(
        url: AppUrl.updateBusinessProfile(businessId),
        body: body,
      );

      if (response.isSuccess) {
        // Refresh the local business model with the new data
        await fetchBusinessProfile(businessId, isRefresh: true);
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Update failed";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      setLoading(false);
      update();
    }
  }














  /// =========================
  /// CLEAR STATE
  /// =========================
  void clear() {
    business = null;
    _errorMessage = null;
    isLoading = false;
    update();
  }














}