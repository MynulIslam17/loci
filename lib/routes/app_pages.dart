import 'package:get/get.dart';
import 'package:loci/presentation/pages/splash_screen.dart';
import 'package:loci/routes/app_routes.dart';

abstract class AppPages {
  static const String initialRoutes = AppRoutes.splash;

  static final pages = [

    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),

  ];
}
