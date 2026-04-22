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
  static const String eventManualCheckIn="$baseUrl/events/check-in";
  static const String createEvent="$baseUrl/events";



  ///===========================  routes ===================================================
  static const String routeList="$baseUrl/routes";
  static  String routeDetails(String routeId)=>"$baseUrl/routes/$routeId";
  static  String routeManualCheckIn="$baseUrl/routes/check-in";
  static const String createRoute="$baseUrl/routes";

  ///-------------raffle--------------------------------
  static const String raffles="$baseUrl/raffles";
  static  String rafflesDetails(String raffleId)=>"$baseUrl/raffles/$raffleId";
  static const String searchTask="$baseUrl/raffles/search";


  ///-----check_in----------------
  static const String checkIn="$baseUrl/checkins/scan";


///-------business
  static const String myBusiness="$baseUrl/businesses/me";
  static const String createBusiness="$baseUrl/businesses";
  static  String businessProfile(String businessId)=>"$baseUrl/businesses/$businessId";
  static  String updateBusinessProfile(String businessId)=>"$baseUrl/businesses/$businessId";





  ///--------------- profile

  static const String getMyProfile="$baseUrl/auth/me";
  static const String updateMyProfile="$baseUrl/users/me";















}