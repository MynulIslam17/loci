// import 'package:flutter/cupertino.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/src/extension_instance.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:loci/core/constants/app_url.dart';
// import 'package:loci/core/network/network_response.dart';
//
// import '../../../core/network/network_caller.dart';
// import '../../../data/network/checkin_item.dart';
// import '../../../data/network/connection_item.dart';
// import '../../../data/network/dashboard_activity.dart';
// import '../../../data/network/dashboard_count.dart';
// import '../../../data/network/dashboard_response.dart';
//
// class DashboardController extends GetxController {
//   // ─── State ───────────────────────────────────────────
//   bool isLoading = false;
//   String? errorMessage;
//
//   DashboardCounts? counts;
//   DashboardActivity<CheckInItem>? checkIns;
//   DashboardActivity<ConnectionItem>? connections;
//
//   NetworkType currentType = NetworkType.checkins;
//
//   // ─── Init ─────────────────────────────────────────────
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDashboard(NetworkType.checkins);
//   }
//
//   // ─── Fetch ────────────────────────────────────────────
//   // ─── Fetch ────────────────────────────────────────────
//   Future<void> fetchDashboard(NetworkType type) async {
//     currentType = type;
//     errorMessage = null;
//     _setLoading(true);
//
//     final String url = dashboardUrl(type);
//     final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
//       url: url,
//     );
//
//     if (response.isSuccess && response.body != null) {
//       _parseResponse(type, response.body!);
//     } else {
//       errorMessage = response.errorMessage;
//     }
//
//     _setLoading(false);
//   }
//
//   // ─── Parse based on type ──────────────────────────────
//   void _parseResponse(NetworkType type, Map<String, dynamic> json) {
//     switch (type) {
//       case NetworkType.checkins:
//         final response = DashboardResponse<CheckInItem>.fromJson(
//           json,
//           CheckInItem.fromJson,
//         );
//         counts = response.counts;
//         checkIns = response.activity;
//         break;
//
//       case NetworkType.connections:
//         final response = DashboardResponse<ConnectionItem>.fromJson(
//           json,
//           ConnectionItem.fromJson,
//         );
//         counts = response.counts;
//         connections = response.activity;
//         break;
//
//       case NetworkType.unknown:
//         break;
//     }
//   }
//
//   // ---------make url -------------
//   static String dashboardUrl(NetworkType type) {
//     final typeParam = switch (type) {
//       NetworkType.checkins => 'checkins',
//       NetworkType.connections => 'connections',
//       NetworkType.unknown => '',
//     };
//     return '${AppUrl.networkDashboard}?type=$typeParam';
//   }
//
//   // ─── Switch tab ───────────────────────────────────────
//   void switchType(NetworkType type) {
//     if (currentType == type || isLoading) return;
//     fetchDashboard(type);
//   }
//
//   // ─── Refresh ──────────────────────────────────────────
//   Future<void> refresh() => fetchDashboard(currentType);
//
//   // ─── Helper ───────────────────────────────────────────
//   void _setLoading(bool value) {
//     isLoading = value;
//     update();
//   }
// }
