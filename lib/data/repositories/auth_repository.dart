


import '../datasources/local_storage_service.dart';
import '../models/user/user_model.dart';

class AuthRepository {
  final LocalStorageService _storage;

  AuthRepository(this._storage);

  Future<void> saveUserData({
    required UserModel model,
    required String token,
  }) async {
    await _storage.saveToken(token);
    await _storage.saveUserModel(model);
  }

  Future<({UserModel? user, String? token, String? role})> loadUserData() async {
    final user = await _storage.getUserModel();
    final token = await _storage.getToken();
    final role = await _storage.getRole();
    return (user: user, token: token, role: role);
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _storage.saveUserModel(updatedUser);
  }

  Future<void> clearUserData() async {
    await _storage.clearAll();
  }
}