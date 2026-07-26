import 'dart:io';

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Profile data layer: remote HTTP via [NetworkCaller].
class ProfileRepository {
  final NetworkCaller _network;

  ProfileRepository(this._network);

  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _network.getRequest(url: AppUrl.getMyProfile);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load profile');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final res = await _network.patchRequest(
      url: AppUrl.updateMyProfile,
      body: body,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to update profile');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> updateAvatar(File file) async {
    final res = await _network.multipartRequest(
      url: AppUrl.updateMyProfile,
      method: 'PATCH',
      files: {'avatar': file},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Upload failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _network.patchRequest(
      url: AppUrl.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to change password');
    }
    return res.body ?? const {};
  }

  Future<void> deleteAccount(String password) async {
    final res = await _network.deleteRequest(
      url: AppUrl.deleteAccount,
      body: {'password': password},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to delete account');
    }
  }
}
