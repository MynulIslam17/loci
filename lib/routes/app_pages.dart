import 'package:get/get.dart';
import 'package:loci/presentation/pages/auth/forget_pass_screen.dart';
import 'package:loci/presentation/pages/auth/login_screen.dart';
import 'package:loci/presentation/pages/auth/otp_screen.dart';
import 'package:loci/presentation/pages/auth/reset_pass_sceen.dart';
import 'package:loci/presentation/pages/auth/signup_screen.dart';
import 'package:loci/presentation/pages/browse/business_profile_screen.dart';
import 'package:loci/presentation/pages/event/event_details.dart';
import 'package:loci/presentation/pages/network/connection_screen.dart';
import 'package:loci/presentation/pages/network/metting_screen.dart';
import 'package:loci/presentation/pages/network/referrals_screen.dart';
import 'package:loci/presentation/pages/network/schedule_meeting_screen.dart';
import 'package:loci/presentation/pages/network/send_new_referrals_screen.dart';
import 'package:loci/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:loci/presentation/pages/splash/splash_screen.dart';
import 'package:loci/presentation/widgets/common/main_bottom_nav.dart';
import 'package:loci/routes/app_routes.dart';

import '../presentation/pages/browse/browse_businesses.dart';

abstract class AppPages {
  static const String initialRoutes = AppRoutes.splash;

  static final pages = [

    /// ==========================Auth=============================
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.onBoarding, page: () => OnboardingScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    GetPage(name: AppRoutes.forgetPass, page: () => ForgetPassScreen()),
    GetPage(name: AppRoutes.otp, page: () => OtpScreen()),
    GetPage(name: AppRoutes.passReset, page: () => ResetPassSceen()),



    /// ==========================Bottom Nav=============================
    GetPage(name: AppRoutes.bottomNav, page: ()=>MainBottomNav()),


    // ----- event details

    GetPage(name: AppRoutes.eventDetails, page: () => EventDetails()),

    // ----- browse business
    GetPage(name: AppRoutes.browseBusiness, page: () => BrowseBusinesses()),
    GetPage(name: AppRoutes.businessProfile, page: () => BusinessProfileScreen()),

    // ----- Network
    GetPage(name: AppRoutes.referral, page: () => ReferralsScreen()),
    GetPage(name: AppRoutes.meeting, page: () => MeetingScreen()),
    GetPage(name: AppRoutes.connection, page: () => ConnectionScreen()),
    GetPage(name: AppRoutes.sendReferral, page: () => SendNewReferralsScreen()),
    GetPage(name: AppRoutes.scheduleMeeting, page: () => ScheduleMeetingScreen()),



  ];
}
