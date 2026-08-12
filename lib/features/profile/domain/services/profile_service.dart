import 'dart:io';

import 'package:loci/features/profile/data/models/profile_state.dart';
import 'package:loci/features/profile/data/repositories/profile_repository.dart';

/// Domain orchestration for profile. Controllers call this — never NetworkCaller.
class ProfileService {
  final ProfileRepository _repository;

  ProfileService(this._repository);

  Future<({Map<String, dynamic> user, ProfileStats? stats})>
  getMyProfile() async {
    final body = await _repository.getMyProfile();
    final data = body['data'];
    final user = data?['user'];
    if (user is! Map) {
      throw Exception('User not found');
    }
    final userMap = Map<String, dynamic>.from(user);
    final statsJson = userMap['stats'];
    ProfileStats? stats;
    if (statsJson is Map<String, dynamic>) {
      stats = ProfileStats.fromJson(statsJson);
    }
    return (user: userMap, stats: stats);
  }

  Future<String> updateName(String name) async {
    final body = await _repository.updateProfile({'name': name});
    return body['message']?.toString() ?? 'Updated successfully';
  }

  Future<void> updateAbout(String about) async {
    await _repository.updateProfile({'about': about});
  }

  Future<String?> updateAvatar(File file) async {
    final body = await _repository.updateAvatar(file);
    return _avatarFromResponse(body);
  }

  String? _avatarFromResponse(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map) {
      final direct = data['avatar']?.toString();
      if (direct != null && direct.isNotEmpty) return direct;
      final user = data['user'];
      if (user is Map) {
        final nested = user['avatar']?.toString();
        if (nested != null && nested.isNotEmpty) return nested;
      }
    }
    return body['avatar']?.toString();
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    return body['message']?.toString() ?? 'Password changed successfully';
  }

  Future<void> deleteAccount(String password) =>
      _repository.deleteAccount(password);
}
