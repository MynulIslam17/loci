import 'dart:io';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';

import '../../../data/models/profile/profile_state.dart';
import '../auth/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final NetworkCaller _network = Get.find<NetworkCaller>();

  // -------------------------
  // UI State
  // -------------------------
  bool isLoading = false;
  File? profileImage; // local preview only
  ProfileStats? stats;

  // -------------------------
  // Getters (Single Source of Truth)
  // -------------------------
  String get userName => _auth.userModel?.name ?? '';
  String get about => _auth.userModel?.about ?? '';
  String? get profileImageUrl => _auth.userModel?.avatar;

  // -------------------------
  // Internal Helpers
  // -------------------------
  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  Future<void> _updateUserModel({
    String? name,
    String? avatar,
    String? about,
  }) async {

    final user = _auth.userModel;
    if (user == null) return;

    await _auth.updateUser(
      user.copyWith(
        name: name ?? user.name,
        avatar: avatar ?? user.avatar,
        about: about ?? user.about,
      ),
    );
  }

  // -------------------------
  // Fetch Profile (Silent)
  // -------------------------
  Future<void> silentFetchProfile() async {
    try {
      final res = await _network.getRequest(url: AppUrl.getMyProfile);

      if (!res.isSuccess || res.body == null) return;

      final data = res.body?['data'];
      final user = data?['user'];

      if (user == null) return;

      //  safe stats access
      final statsJson = user['stats'];

      if (statsJson != null) {
        stats = ProfileStats.fromJson(statsJson);
      }

      await _updateUserModel(
        name: user['name'],
        avatar: user['avatar'],
        about: user['about'],
      );

      update();
    } catch (_) {
      SnackbarService.error('Something went wrong');
    }
  }
  // -------------------------
  // Manual Refresh
  // -------------------------
  Future<void> fetchProfile() async {
    _setLoading(true);

    try {
      final res = await _network.getRequest(url: AppUrl.getMyProfile);

      if (!res.isSuccess || res.body == null) {
        SnackbarService.error(
          res.errorMessage ?? 'Failed to load profile',
        );
        return;
      }

      final data = res.body?['data'];
      final user = data?['user'];

      if (user == null) {
        SnackbarService.error('User not found');
        return;
      }

      final statsJson = user['stats'];


      // Update user

      await _updateUserModel(
        name: user['name'],
        avatar: user['avatar'],
        about: user['about'],
      );


      // Update stats

      if (statsJson != null) {
        stats = ProfileStats.fromJson(statsJson);
      }

      update();
    } catch (_) {
      SnackbarService.error('Something went wrong');
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------
  // Update Name
  // -------------------------
  Future<void> updateName(String value) async {
    final old = userName;

    // Optimistic update
    await _updateUserModel(name: value);
    update();

    _setLoading(true);

    try {
      final res = await _network.patchRequest(
        url: AppUrl.updateMyProfile,
        body: {'name': value},
      );

      if (res.isSuccess) {
        Get.back();
        SnackbarService.success(
          res.body?['message'] ?? 'Updated successfully',
        );
      } else {
        await _updateUserModel(name: old); // rollback
        update();
        SnackbarService.error(
          res.errorMessage ?? 'Failed to update name',
        );
      }
    } catch (_) {
      await _updateUserModel(name: old); // rollback
      update();
      SnackbarService.error('Something went wrong');
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------
  // Update About
  // -------------------------
  Future<void> updateAbout(String value) async {
    final old = about;

    // Optimistic update
    await _updateUserModel(about: value);
    update();

    _setLoading(true);

    try {
      final res = await _network.patchRequest(
        url: AppUrl.updateMyProfile,
        body: {'about': value},
      );

      if (res.isSuccess) {
        Get.back();
        SnackbarService.success('About updated');
      } else {
        await _updateUserModel(about: old); // rollback
        update();
        SnackbarService.error(
          res.errorMessage ?? 'Failed to update about',
        );
      }
    } catch (_) {
      await _updateUserModel(about: old); // rollback
      update();
      SnackbarService.error('Something went wrong');
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------
  // Update Profile Image
  // -------------------------
  Future<void> updateImage(File file) async {
    // Local preview
    profileImage = file;
    update();

    _setLoading(true);

    try {
      final res = await _network.multipartRequest(
        url: AppUrl.updateMyProfile,
        method: 'PATCH',
        files: {'avatar': file},
      );

      if (res.isSuccess) {
        final newAvatar = res.body?['data']?['user']?['avatar'];

        await _updateUserModel(avatar: newAvatar);
        profileImage = null; // clear temp after success
        update();

        SnackbarService.success('Profile image updated');
      } else {
        profileImage = null; // rollback preview
        update();

        SnackbarService.error(
          res.errorMessage ?? 'Upload failed',
        );
      }
    } catch (_) {
      profileImage = null;
      update();
      SnackbarService.error('Something went wrong');
    } finally {
      _setLoading(false);
    }
  }
}