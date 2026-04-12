import 'dart:io';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import '../auth/auth_controller.dart';

class ProfileController extends GetxController {
  final _auth = Get.find<AuthController>();
  final _network = Get.find<NetworkCaller>();

  // -------------------------
  // State
  // -------------------------
  String userName = '';
  String about = '';
  File? profileImage;
  String? profileImageUrl;
  bool isLoading = false;

  // -------------------------
  // Init — load from cache instantly
  // -------------------------
  @override
  void onInit() {
    super.onInit();
    _loadFromAuth();
  }

  // -------------------------
  // Internal
  // -------------------------

  void _loadFromAuth() {
    final user = _auth.userModel;
    if (user == null) return;
    userName = user.name;
    profileImageUrl = user.avatar;
    update();
  }

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  Future<void> _syncAuth() async {
    final user = _auth.userModel;
    if (user == null) return;
    await _auth.updateUser(
      user.copyWith(
        name: userName,
        avatar: profileImageUrl,
      ),
    );
  }

  // -------------------------
  // Silent fetch — called from screen initState
  // -------------------------
  Future<void> silentFetchProfile() async {
    try {
      final response = await _network.getRequest(url: AppUrl.getMyProfile);
      if (!response.isSuccess || response.body == null) return;

      final user = response.body?['data']?['user'];
      if (user == null) return;

      userName = user['name'] ?? userName;
      profileImageUrl = user['avatar'] ?? profileImageUrl;
      update();

      await _syncAuth(); // ✅ keep cache fresh
    } catch (_) {
      // silent — no error shown to user
    }
  }

  // -------------------------
  // Manual refresh
  // -------------------------
  Future<void> fetchProfile() async {
    _setLoading(true);

    try {
      final response = await _network.getRequest(url: AppUrl.getMyProfile);

      if (response.isSuccess && response.body != null) {
        final user = response.body?['data']?['user'];
        if (user == null) return;

        userName = user['name'] ?? userName;
        profileImageUrl = user['avatar'] ?? profileImageUrl;
        update();

        await _syncAuth();
      } else {
        SnackbarService.error(
            response.errorMessage ?? 'Failed to load profile');
      }
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
    userName = value; // optimistic
    update();

    _setLoading(true);

    try {
      final response = await _network.patchRequest(
        url: AppUrl.updateMyProfile,
        body: {'name': value},
      );

      if (response.isSuccess) {
        await _syncAuth(); // ✅ sync after update
        Get.back();
        SnackbarService.success(
            response.body?['message'] ?? 'Updated successfully');
      } else {
        userName = old; // rollback
        update();
        SnackbarService.error(
            response.errorMessage ?? 'Failed to update name');
      }
    } catch (_) {
      userName = old;
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
    about = value; // optimistic
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
        about = old; // rollback
        update();
        SnackbarService.error(res.errorMessage ?? 'Failed to update about');
      }
    } catch (_) {
      about = old;
      update();
      SnackbarService.error('Something went wrong');
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------
  // Update Image
  // -------------------------
  Future<void> updateImage(File file) async {
    _setLoading(true);

    try {
      final res = await _network.multipartRequest(
        url: AppUrl.updateMyProfile,
        method: 'PATCH',
        files: {'avatar': file},
      );

      if (res.isSuccess) {
        profileImage = file;
        profileImageUrl = res.body?['data']?['user']?['avatar'];
        update();

        await _syncAuth(); // ✅ sync after image update
        SnackbarService.success('Profile image updated');
      } else {
        SnackbarService.error(res.errorMessage ?? 'Upload failed');
      }
    } catch (_) {
      SnackbarService.error('Something went wrong');
    } finally {
      _setLoading(false);
    }
  }
}