import 'package:get/get.dart';
import 'package:loci/routes/app_routes.dart';

/// Universal 1-line launcher to open in-app Live Navigation from anywhere in the app
/// (Events, Routes, Businesses, Places, Raffles, Activities).
class LiveNavigationLauncher {
  LiveNavigationLauncher._();

  /// Opens the live navigation screen for a specific destination coordinate
  static Future<T?>? open<T>({
    required double latitude,
    required double longitude,
    String title = 'Destination',
    String? locationLabel,
  }) {
    if (latitude == 0.0 && longitude == 0.0) return null;

    return Get.toNamed<T>(
      AppRoutes.liveNavigation,
      arguments: {
        'latitude': latitude,
        'longitude': longitude,
        'title': title.trim().isNotEmpty ? title.trim() : 'Destination',
        'locationLabel': locationLabel?.trim(),
      },
    );
  }
}
