abstract class AppUrl {

  /// base url=================================
  static const String baseUrl="https://jakuan5000.syedbipul.me/api/v1";


  /// ========================auth===================================

  static const String signUp="$baseUrl/auth/register";
  static const String login="$baseUrl/auth/login";
  static const String verifyEmail="$baseUrl/auth/verify-email";
  static const String resendOtp="$baseUrl/auth/resend-verification";
  static const String resetPass="$baseUrl/auth/reset-password";






  ///=============================================== profile ===============================================

  static const String updateProfile="$baseUrl/user/update-my-profile";
  static const String getProfile="$baseUrl/user/get-my-profile";











}