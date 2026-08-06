import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _moveToNextScreen();
  }

  void _moveToNextScreen() async {
    final authController = Get.find<AuthController>();

    // Ensure session data is fully loaded from local storage before checking auth state
    await Future.wait([
      authController.loadUserData(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (!mounted) return;

    //--- if login then go to bottom nav else go to onboarding

    if (authController.isLoggedIn) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else {
      Get.offAllNamed(AppRoutes.onBoarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primaryContainer.withOpacity(0.8),

      body: Center(child: Image.asset(Assets.images.logoPng.path)),
    );
  }
}
