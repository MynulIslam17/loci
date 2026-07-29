import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/data/models/my_ad_model.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class MyBusinessProfileController extends GetxController {
  MyBusinessProfileController(this._service);

  final MyBusinessService _service;

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  final RxnString errorMessage = RxnString();
  final Rxn<BusinessProfileModel> business = Rxn<BusinessProfileModel>();

  final RxList<MyAdModel> myAds = <MyAdModel>[].obs;
  final RxBool isLoadingAds = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }

  Future<bool> fetchBusinessProfile(
    String businessId, {
    bool isRefresh = false,
  }) async {
    try {
      if (!isRefresh) {
        setLoading(true);
      }

      errorMessage.value = null;
      business.value = await _service.getBusinessProfile(businessId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      if (!isRefresh) {
        setLoading(false);
      }
    }
  }

  Future<void> silentRefresh(String businessId) async {
    try {
      business.value = await _service.getBusinessProfile(businessId);
      await fetchMyAds(businessId: businessId, isRefresh: true);
    } catch (_) {
      // ignore silent errors
    }
  }

  Future<void> fetchMyAds({
    required String businessId,
    bool isRefresh = false,
  }) async {
    if (businessId.isEmpty) return;

    try {
      if (!isRefresh) {
        isLoadingAds.value = true;
      }
      myAds.assignAll(
        await _service.getMyAds(businessId: businessId),
      );
    } catch (_) {
      if (!isRefresh) {
        myAds.clear();
      }
    } finally {
      if (!isRefresh) {
        isLoadingAds.value = false;
      }
    }
  }

  Future<bool> updateBusinessText({
    required String businessId,
    required Map<String, dynamic> body,
    bool silentSync = true,
  }) async {
    if (body.isEmpty) return true;

    try {
      errorMessage.value = null;

      final data = await _service.updateBusinessText(
        businessId: businessId,
        body: body,
      );

      business.value = business.value?.copyWith(
        name: data['name'],
        description: data['description'],
        location: data['location'],
        phone: data['phone'],
        category: data['category'],
      );

      if (silentSync) {
        silentRefresh(businessId);
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> uploadBusinessImages({
    required String businessId,
    File? logo,
    List<File>? photos,
  }) async {
    try {
      isUpdating.value = true;

      final data = await _service.uploadBusinessImages(
        businessId: businessId,
        logo: logo,
        photos: photos,
      );

      business.value = business.value?.copyWith(
        logo: data['logo'] ?? business.value?.logo,
        photos: List<String>.from(data['photos'] ?? []),
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<bool> removeBusinessPhoto({
    required String businessId,
    required String photoUrl,
  }) async {
    try {
      isUpdating.value = true;

      final data = await _service.removeBusinessPhoto(
        businessId: businessId,
        photoUrl: photoUrl,
      );

      business.value = business.value?.copyWith(
        photos: List<String>.from(data['photos'] ?? []),
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  void clear() {
    business.value = null;
    errorMessage.value = null;
    isLoading.value = false;
    isUpdating.value = false;
  }
}
