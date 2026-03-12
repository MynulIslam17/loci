import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loci/core/theme/app_theme.dart';
import 'package:loci/presentation/bindings/app_bindings.dart';
import 'package:loci/routes/app_pages.dart';

void main() async {
  // Ensure Flutter is initialized before calling GetStorage
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(Loci());
}

class Loci extends StatelessWidget {
  const Loci({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    // Read the saved value
    bool? isDarkMode = box.read('isDarkMode');

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
          // Set initial theme based on storage
          themeMode: isDarkMode == null
              ? ThemeMode.system
              : (isDarkMode ? ThemeMode.dark : ThemeMode.light),
          initialBinding: AppBindings(),
          getPages: AppPages.pages,
          initialRoute: AppPages.initialRoutes,
        );
      },
    );
  }
}