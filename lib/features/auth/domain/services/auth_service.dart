import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/data/repositories/auth_repository.dart';

/// Domain orchestration for auth. Controllers call this — never NetworkCaller.
class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  /// Returns (user, token) on success.
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final body = await _repository.login(email: email, password: password);
    final inner = body['data'];
    if (inner is! Map) throw Exception('Invalid login response');

    final userJson = inner['user'];
    final token = (inner['accessToken'] ?? inner['token'])?.toString();
    if (userJson == null || token == null || token.isEmpty) {
      throw Exception('Invalid login response');
    }

    final user = UserModel.fromJson(Map<String, dynamic>.from(userJson as Map));
    await _repository.saveUserData(model: user, token: token);
    return (user: user, token: token);
  }

  Future<String> signup({
    required String name,
    required String email,
    required String password,
    required String zipCode,
    required String dateOfBirth,
  }) async {
    final body = await _repository.signup(
      name: name,
      email: email,
      password: password,
      zipCode: zipCode,
      dateOfBirth: dateOfBirth,
    );
    return body['message']?.toString() ?? '';
  }

  Future<({UserModel? user, String? token, String message})> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    final body = await _repository.verifySignupOtp(email: email, otp: otp);
    final message = body['message']?.toString() ?? 'OTP verified successfully';

    UserModel? user;
    String? token;
    final inner = body['data'];
    if (inner is Map) {
      final userJson = inner['user'];
      token = inner['accessToken'] as String?;
      if (userJson != null && token != null) {
        user = UserModel.fromJson(Map<String, dynamic>.from(userJson as Map));
        await _repository.saveUserData(model: user, token: token);
      }
    }
    return (user: user, token: token, message: message);
  }

  Future<String> verifyForgotOtp({
    required String email,
    required String otp,
  }) async {
    final body = await _repository.verifyForgotOtp(email: email, otp: otp);
    return body['message']?.toString() ?? 'OTP verified successfully';
  }

  Future<String> sendForgotOtp({required String email}) async {
    final body = await _repository.sendForgotOtp(email: email);
    return body['message']?.toString() ?? 'OTP sent successfully';
  }

  Future<String> resendOtp({required String email}) async {
    final body = await _repository.resendOtp(email: email);
    return body['message']?.toString() ?? 'OTP Re-sent successfully';
  }

  Future<String> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final body = await _repository.resetPassword(
      email: email,
      newPassword: newPassword,
    );
    return body['message']?.toString() ?? 'Password reset successfully';
  }

  /// Fetches the current user from `/auth/me`, persists it locally (so the
  /// refreshed role survives an app restart) and returns it.
  Future<UserModel> getMe() async {
    final body = await _repository.getMe();
    final data = body['data'];
    final userJson = data is Map ? data['user'] : null;
    if (userJson is! Map) throw Exception('User not found');
    final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));
    await _repository.updateUser(user);
    return user;
  }

  Future<({UserModel? user, String? token, String? role})> loadSession() {
    return _repository.loadUserData();
  }

  Future<void> saveSession({required UserModel model, required String token}) {
    return _repository.saveUserData(model: model, token: token);
  }

  Future<void> updateUser(UserModel user) => _repository.updateUser(user);

  Future<void> saveRememberMe({required bool remember, String? email}) =>
      _repository.saveRememberMe(remember: remember, email: email);

  Future<({bool remember, String? email})> getRememberMe() =>
      _repository.getRememberMe();

  Future<void> clearSession() => _repository.clearUserData();
}
