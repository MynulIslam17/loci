import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loci/core/di/bindings/app_bindings.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/core/theme/app_theme.dart';
import 'package:loci/core/utils/system_ui_config.dart';
import 'package:loci/features/push_notification/domain/services/push_notification_service.dart';
import 'package:loci/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.bootstrap();

  await GetStorage.init();
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  final hiveStorage = await HiveStorageService.init();
  Get.put<HiveStorageService>(hiveStorage, permanent: true);
  Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
  await SystemUiConfig.init();
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
          builder: SystemUiConfig.wrapApp,
        );
      },
    );
  }
}