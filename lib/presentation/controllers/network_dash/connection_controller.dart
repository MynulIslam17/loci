import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../core/enums/network_type.dart';
import '../../../data/models/network/checkin_item.dart';
import '../../../data/models/network/connection_item.dart';
import '../../../data/models/network/dashboard_activity.dart';
import '../../../data/models/network/dashboard_count.dart';
import '../../../data/models/network/dashboard_response.dart';
import '../../../data/models/network/raferral_item.dart';

class ConnectionController extends GetxController {
  bool isLoading = false;
  String? errorMessage;

  DashboardCounts? counts;

  // ================= CACHE =================
  DashboardActivity? _checkinsActivity;
  DashboardActivity? _connectionsActivity;
  DashboardActivity? _meetingsActivity;
  DashboardActivity? _referralsActivity;

  // ================= FETCH =================
  Future<void> fetchDashboard(NetworkType type) async {
    try {
      isLoading = true;
      errorMessage = null;
      update();

      final url = _dashboardUrl(type);

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.isSuccess && response.body != null) {
        final model = DashboardResponse.fromJson(response.body!);

        // global counts
        counts = model.data.counts;

        // cache per type
        switch (type) {
          case NetworkType.checkins:
            _checkinsActivity = model.data.activity;
            break;

          case NetworkType.connections:
            _connectionsActivity = model.data.activity;
            break;

          case NetworkType.meetings:
            _meetingsActivity = model.data.activity;
            break;

          case NetworkType.referrals:
            _referralsActivity = model.data.activity;
            break;

          default:
            break;
        }
      } else {
        errorMessage = response.errorMessage ?? "Something went wrong";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }

  // ================= REFRESH =================
  Future<void> refreshDashboard(NetworkType type) async {
    switch (type) {
      case NetworkType.checkins:
        _checkinsActivity = null;
        break;
      case NetworkType.connections:
        _connectionsActivity = null;
        break;
      case NetworkType.meetings:
        _meetingsActivity = null;
        break;
      case NetworkType.referrals:
        _referralsActivity = null;
        break;
      default:
        break;
    }

    await fetchDashboard(type);
  }

  // ================= URL =================
  String _dashboardUrl(NetworkType type) {
    final typeParam = switch (type) {
      NetworkType.checkins => 'checkins',
      NetworkType.connections => 'connections',
      NetworkType.meetings => 'meetings',
      NetworkType.referrals => 'referrals',
      NetworkType.unknown => '',
    };

    return '${AppUrl.networkDashboard}?type=$typeParam';
  }

  // ================= GETTERS =================

  List<CheckInModel> get checkins {
    final data = _checkinsActivity?.data;
    if (data == null) return [];
    return data.cast<CheckInModel>();
  }

  List<ConnectionModel> get connections {
    final data = _connectionsActivity?.data;
    if (data == null) return [];
    return data.cast<ConnectionModel>();
  }


  List<dynamic> get meetings {
    final data = _meetingsActivity?.data;
    if (data == null) return [];
    return data;
  }

  List<ReferralModel> get referrals {
    final data = _referralsActivity?.data;
    if (data == null) return [];
    return data.cast<ReferralModel>();
  }

  // ================= STATE HELPERS =================

  bool hasData(NetworkType type) {
    switch (type) {
      case NetworkType.checkins:
        return _checkinsActivity?.data.isNotEmpty ?? false;

      case NetworkType.connections:
        return _connectionsActivity?.data.isNotEmpty ?? false;

      case NetworkType.meetings:
        return _meetingsActivity?.data.isNotEmpty ?? false;

      case NetworkType.referrals:
        return _referralsActivity?.data.isNotEmpty ?? false;

      default:
        return false;
    }
  }
}