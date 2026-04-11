abstract class AppUrl {

  /// base url=================================
  //static const String baseUrl="https://jakuan5000.syedbipul.me/api/v1";//local
  static const String baseUrl="https://jakuan5000.syedbipul.me/api/v1"; //live


  /// ========================auth===================================

  static const String signUp="$baseUrl/auth/register";
  static const String login="$baseUrl/auth/login";
  static const String forgetPassword="$baseUrl/auth/forgot-password";
  static const String verifySignupOtp="$baseUrl/auth/verify-email";
  static const String verifyForgotOtp="$baseUrl/auth/verify-reset-otp";
  static const String resendOtp="$baseUrl/auth/resend-verification";
  static const String resetPassword="$baseUrl/auth/reset-password";






  ///=============================================== event ===============================================

  static const String eventList="$baseUrl/events";
  static  String rsvpEvent(String eventId)=>"$baseUrl/events/$eventId/rsvp";
  static String eventDetails(String id)=>"$baseUrl/events/$id";
  static String eventManualCheckIn(String checkInCode)=>"$baseUrl/events/check-in";



  ///===========================  routes ===================================================
  static const String routeList="$baseUrl/routes";
  static  String routeDetails(String routeId)=>"$baseUrl/routes/$routeId";

  ///-------------raffle--------------------------------



  ///-----check_in----------------
  static const String checkIn="$baseUrl/checkins/scan";



















  static const String getProfile="$baseUrl/user/get-my-profile";











}