import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/user_model.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';

class VerifyEmailController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  ///  signup verify — when comes from -> signup screen
  Future<bool> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update();

    try {
      final NetworkResponse response = await Get.find<NetworkCaller>()
          .postRequest(
            url: AppUrl.verifySignupOtp,
            body: {'email': email, 'otp': otp},
          );

      if (response.isSuccess && response.body != null) {
        final data = response.body!;
        _successMessage = data["message"] ?? "OTP verified successfully";

        final innerData = data["data"];
        if (innerData != null) {
          final userJson = innerData["user"];
          final String? token = innerData["accessToken"];

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
        _errorMessage = response.errorMessage ?? "Verification failed";
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

  /// forgot verify —> when comes from -> forget password screen

  Future<bool> verifyForgotOtp({
    required String email,
    required String otp,
  }) async {

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update();
    
    try{
      
      final NetworkResponse response=await Get.find<NetworkCaller>().postRequest(url: AppUrl.verifyForgotOtp,body: {'email': email, 'otp': otp});

      if(response.isSuccess && response.body != null){
        _successMessage=response.body!["message"] ?? "OTP verified successfully";
        return true;

      }else{
        _errorMessage=response.errorMessage ?? "Verification failed";
        return false;
      }
      
      
    }catch (e){

      _errorMessage = "An error occurred: $e";
      return false;
      
    }finally{
      _isLoading = false;
      update();
    }





  }
}
