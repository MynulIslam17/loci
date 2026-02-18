import 'package:get/get.dart';
import 'package:loci/presentation/pages/auth/forget_pass_screen.dart';
import 'package:loci/presentation/pages/auth/login_screen.dart';
import 'package:loci/presentation/pages/auth/otp_screen.dart';
import 'package:loci/presentation/pages/auth/reset_pass_sceen.dart';
import 'package:loci/presentation/pages/auth/signup_screen.dart';
import 'package:loci/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:loci/presentation/pages/splash/splash_screen.dart';
import 'package:loci/presentation/widgets/common/main_bottom_nav.dart';
import 'package:loci/routes/app_routes.dart';

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
    GetPage(name: AppRoutes.bottomNav, page: ()=>MainBottomNav())






  ];
}
