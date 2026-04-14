import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

class SignupController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Sign up user with name, email, password, zipCode, dateOfBirth
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String zipCode,
    required String dateOfBirth, // ISO string "YYYY-MM-DD"
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update(); // Notify UI

    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'zipCode': zipCode,
        'dateOfBirth': dateOfBirth,
      };

      final NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.signUp,
        body: body,
      );

      if (response.isSuccess && response.body != null) {
        _successMessage = (response.body as Map<String, dynamic>)["message"] ?? "";
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Signup failed";
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
      return false;
    } finally {
      _isLoading = false;
      update(); // Always stop loading, even if exception occurs
    }
  }
}