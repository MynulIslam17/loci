import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/storage/local_storage_service.dart';
import 'package:loci/features/auth/data/models/user_model.dart';

/// Auth data layer: remote HTTP via [NetworkCaller] + local session persistence.
class AuthRepository {
  final NetworkCaller _network;
  final LocalStorageService _storage;

  AuthRepository(this._network, this._storage);

  // ---------------------------------------------------------------------------
  // Remote
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.login,
      isFromLogin: true,
      body: {'email': email, 'password': password},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Login failed');
    }
    return res.body!;
  }

  /// Best-effort server logout. Failures are ignored by the caller.
  Future<void> logoutRemote() async {
    final res = await _network.postRequest(url: AppUrl.logout, body: {});
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Logout failed');
    }
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String zipCode,
    required String dateOfBirth,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.signUp,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'zipCode': zipCode,
        'dateOfBirth': dateOfBirth,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Signup failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.verifySignupOtp,
      body: {'email': email, 'otp': otp},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Verification failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> verifyForgotOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.verifyForgotOtp,
      body: {'email': email, 'otp': otp},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Verification failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> sendForgotOtp({required String email}) async {
    final res = await _network.postRequest(
      url: AppUrl.forgetPassword,
      body: {'email': email},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to send OTP');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final res = await _network.postRequest(
      url: AppUrl.resendOtp,
      body: {'email': email},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to resend OTP');
    }
    return res.body ?? const {};
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.resetPassword,
      body: {'email': email, 'newPassword': newPassword},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Password reset failed');
    }
    return res.body!;
  }

  /// Current user from `GET /auth/me` — reflects the latest role (e.g. after
  /// claiming a business promotes a member to business_owner).
  Future<Map<String, dynamic>> getMe() async {
    final res = await _network.getRequest(url: AppUrl.getMyProfile);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load user');
    }
    return res.body!;
  }

  // ---------------------------------------------------------------------------
  // Local session
  // ---------------------------------------------------------------------------

  Future<void> saveUserData({
    required UserModel model,
    required String token,
  }) async {
    await _storage.saveToken(token);
    await _storage.saveUserModel(model);
  }

  Future<({UserModel? user, String? token, String? role})>
  loadUserData() async {
    final user = await _storage.getUserModel();
    final token = await _storage.getToken();
    final role = await _storage.getRole();
    return (user: user, token: token, role: role);
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _storage.saveUserModel(updatedUser);
  }

  Future<void> saveRememberMe({required bool remember, String? email}) async {
    await _storage.saveRememberMe(remember: remember, email: email);
  }

  Future<({bool remember, String? email})> getRememberMe() async {
    return _storage.getRememberMe();
  }

  Future<void> clearUserData() async {
    await _storage.clearAll();
  }
}
