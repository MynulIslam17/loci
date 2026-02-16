abstract class AppUrl {

  /// base url=================================
  static const String baseUrl="https://mqf4rflf-6000.asse.devtunnels.ms/api/v1";


  /// ========================auth===================================

  static const String registerMechanic="$baseUrl/auth/register/mechanic";
  static const String login="$baseUrl/auth/login";
  static const String forgetPass="$baseUrl/auth/forgot-password";
  static const String verifyOtp="$baseUrl/auth/forgot-otp-verify";
  static const String resetPass="$baseUrl/auth/reset-password";
  static const String resendOtp="$baseUrl/auth/resend-otp";



  /// =========================jobs===================================

/// my services  which can fetch data based on parameter like(data or status
  static String myServices({String? date, String? status}) {

    const String path = "/jobs/get-all/home";

    List<String> params = [];

    if (date != null) params.add("date=$date");
    if (status != null) params.add("status=$status");


    if (params.isEmpty) {
      return "$baseUrl$path";
    } else {

      return "$baseUrl$path?${params.join('&')}";
    }
  }


  static  String jobQuatation(String id)=>"$baseUrl/jobs/add/quatation/$id";


     /// my jobs that is interact with

  static String myJobs(String status) => '$baseUrl/jobs/my-jobs/all?status=$status';
  static String getSingleJob(String id) => '$baseUrl/jobs/find/$id';
  static String jobIncomplete(String id) => '$baseUrl/jobs/quotation-job-in-complete/$id';
  static String jobComplete(String id) => '$baseUrl/jobs/quotation-job-complete/$id';









  ///=============================================== profile ===============================================

  static const String updateProfile="$baseUrl/user/update-my-profile";
  static const String getProfile="$baseUrl/user/get-my-profile";











}