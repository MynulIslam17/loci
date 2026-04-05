import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';

import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';

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
    await Future.delayed(Duration(seconds: 4));

    if (!mounted) return;

     //--- if login then go to bottom nav else go to onboarding

     if(Get.find<AuthController>().isLoggedIn){
       Get.offAllNamed(AppRoutes.bottomNav);
     }else{
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
