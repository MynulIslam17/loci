import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/image_upload_preparer.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/profile/data/models/profile_state.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._service);

  final ProfileService _service;
  final AuthController _auth = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final Rxn<File> _profileImage = Rxn<File>();
  final Rxn<ProfileStats> _stats = Rxn<ProfileStats>();
  final RxInt _avatarRevision = 0.obs;

  bool get isLoading => _isLoading.value;
  File? get profileImage => _profileImage.value;
  ProfileStats? get stats => _stats.value;
  int get avatarRevision => _avatarRevision.value;

  String get userName => _auth.userModel?.name ?? '';
  String get about => _auth.userModel?.about ?? '';
  String? get profileImageUrl => _auth.userModel?.avatar;

  String get memberSince {
    final iso = _auth.userModel?.createdAt;
    if (iso == null || iso.isEmpty) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    return '${DateParserHelper.getMonthName(date)} ${date.day}, ${date.year}';
  }

  @override
  void onInit() {
    super.onInit();
    silentFetchProfile();
  }

  void _setLoading(bool value) {
    _isLoading.value = value;
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

  Future<void> silentFetchProfile() async {
    try {
      final result = await _service.getMyProfile();
      _stats.value = result.stats;
      await _updateUserModel(
        name: result.user['name'],
        avatar: result.user['avatar'],
        about: result.user['about'],
      );
    } catch (_) {
      SnackbarService.error('Something went wrong');
    }
  }

  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      final result = await _service.getMyProfile();
      await _updateUserModel(
        name: result.user['name'],
        avatar: result.user['avatar'],
        about: result.user['about'],
      );
      _stats.value = result.stats;
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateName(String value) async {
    final old = userName;
    await _updateUserModel(name: value);
    _setLoading(true);

    try {
      final message = await _service.updateName(value);
      SnackbarService.success(message);
    } catch (e) {
      await _updateUserModel(name: old);
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAbout(String value) async {
    final old = about;
    await _updateUserModel(about: value);
    _setLoading(true);

    try {
      await _service.updateAbout(value);
      SnackbarService.success('About updated');
    } catch (e) {
      await _updateUserModel(about: old);
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateImage(File file) async {
    _profileImage.value = file;
    _setLoading(true);

    try {
      File toUpload = file;
      String? newAvatar;
      Object? lastError;

      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          if (attempt == 1) {
            toUpload = await ImageUploadPreparer.recompress(
              file,
              quality: 55,
              maxSide: 720,
            );
            _profileImage.value = toUpload;
          }
          newAvatar = await _service.updateAvatar(toUpload);
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
        }
      }

      if (lastError != null) throw lastError;

      if (newAvatar == null || newAvatar.isEmpty) {
        try {
          final result = await _service.getMyProfile();
          newAvatar = result.user['avatar']?.toString();
        } catch (_) {}
      }

      final previousUrl = profileImageUrl;
      if (newAvatar != null && newAvatar.isNotEmpty) {
        await _updateUserModel(avatar: newAvatar);
      }
      if (previousUrl != null && previousUrl.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(previousUrl);
      }
      if (newAvatar != null && newAvatar.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(newAvatar);
      }
      // Always bump — CDN URL often stays the same after overwrite.
      _auth.bumpAvatarRevision();
      _avatarRevision.value = _auth.avatarRevision.value;
      _profileImage.value = null;
      SnackbarService.success('Profile image updated');
    } catch (e) {
      _profileImage.value = null;
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }
}
