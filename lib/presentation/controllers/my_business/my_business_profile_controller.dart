import 'dart:io';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../data/models/busniess/business_profile_model.dart';

class MyBusinessProfileController extends GetxController {
  bool isLoading = false;
  bool isUpdating = false;

  String? _errorMessage;
  BusinessModel? business;

  String? get errorMessage => _errorMessage;

  // =========================
  // SET LOADING
  // =========================
  void setLoading(bool value) {
    isLoading = value;
    update();
  }

  // =========================
  // FETCH BUSINESS PROFILE
  // =========================
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

  // =========================
  // SILENT REFRESH (NO LOADER)
  // =========================
  Future<void> silentRefresh(String businessId) async {
    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.businessProfile(businessId),
      );

      if (response.isSuccess && response.body != null) {
        business = BusinessModel.fromJson(response.body!['data']);
        update();
      }
    } catch (_) {
      // ignore silent errors
    }
  }

  // =========================
  // UPDATE BUSINESS TEXT DATA
  // =========================
  Future<bool> updateBusinessText({
    required String businessId,
    required Map<String, dynamic> body,
    bool silentSync = true,
  }) async {
    try {
      isUpdating = true;
      _errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().patchRequest(
        url: AppUrl.updateBusinessProfile(businessId),
        body: body,
      );

      if (!response.isSuccess || response.body == null) {
        _errorMessage = response.errorMessage ?? "Update failed";
        return false;
      }

      final data = response.body!["data"];

      // =========================
      // OPTIMISTIC UPDATE (FAST UI)
      // =========================
      business = business?.copyWith(
        name: data['name'],
        description: data['description'],
        location: data['location'],
        phone: data['phone'],
        category: data['category'],
      );

      update();

      // =========================
      // OPTIONAL SILENT SYNC
      // =========================
      if (silentSync) {
        silentRefresh(businessId);
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      isUpdating = false;
      update();
    }
  }


  // =========================
  // UPDATE BUSINESS images
  // =========================

  Future<bool> uploadBusinessImages({
    required String businessId,
    File? logo,
    List<File>? photos,
  }) async {
    try {
      isUpdating = true;
      update();

      final Map<String, File> files = {};
      final Map<String, List<File>> multiFiles = {};

      // single file
      if (logo != null) {
        files["logo"] = logo;
      }

      // multiple files
      if (photos != null && photos.isNotEmpty) {
        multiFiles["photos"] = photos;
      }

      final response = await Get.find<NetworkCaller>().multipartRequest(
        url: AppUrl.updateBusinessProfile(businessId),
        method: "PATCH",
        files: files,
        multiFiles: multiFiles,
      );

      if (!response.isSuccess || response.body == null) {
        _errorMessage = response.errorMessage;
        return false;
      }

      final data = response.body!["data"];

      // updated model locally
      business = business?.copyWith(
        logo: data["logo"] ?? business?.logo,
        photos: List<String>.from(data["photos"] ?? []),
      );

      update();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      isUpdating = false;
      update();
    }
  }




  Future<bool> removeBusinessPhoto({
    required String businessId,
    required String photoUrl,
  }) async {
    try {
      isUpdating = true;
      update();

      final response = await Get.find<NetworkCaller>().patchRequest(
        url: AppUrl.updateBusinessProfile(businessId),
        body: {
          "removePhotos": [photoUrl],
        },
      );

      if (!response.isSuccess || response.body == null) {
        _errorMessage = response.errorMessage ?? "Failed to remove photo";
        return false;
      }

      final data = response.body!["data"];

      business = business?.copyWith(
        photos: List<String>.from(data["photos"] ?? []),
      );

      update();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      isUpdating = false;
      update();
    }
  }








  // =========================
  // CLEAR STATE
  // =========================
  void clear() {
    business = null;
    _errorMessage = null;
    isLoading = false;
    isUpdating = false;
    update();
  }
}