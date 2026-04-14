import 'package:get/get.dart';

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/user_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';


class LoginController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.login,
        isFromLogin : true,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess && response.body != null) {
        final innerData = response.body!['data'];

        if (innerData != null) {
          final userJson = innerData['user'];
          final String? token = innerData['accessToken'];

          if (userJson != null && token != null) {
            final user = UserModel.fromJson(userJson);
            await Get.find<AuthController>().saveUserData(
              model: user,
              token: token,
            );
          }
        }
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Login failed";
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }
}