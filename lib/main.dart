import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/app_theme.dart';
import 'package:loci/presentation/bindings/app_bindings.dart';
import 'package:loci/routes/app_pages.dart';
import 'package:loci/routes/app_routes.dart';

void main() {

  runApp(Loci());
}


class Loci extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Loci",
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          initialBinding: AppBindings(),

          getPages: AppPages.pages,
          initialRoute: AppPages.initialRoutes,


        );
      },
    );
  }
}
