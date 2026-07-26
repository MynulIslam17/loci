import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/features/network/data/models/checkin_item.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/data/models/dashboard_activity.dart';
import 'package:loci/features/network/data/models/dashboard_count.dart';
import 'package:loci/features/network/data/models/referral_item.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

class ConnectionController extends GetxController {
  ConnectionController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  final Rxn<DashboardCounts> _counts = Rxn<DashboardCounts>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  DashboardCounts? get counts => _counts.value;

  // ================= CACHE =================
  final Rxn<DashboardActivity> _checkinsActivity = Rxn<DashboardActivity>();
  final Rxn<DashboardActivity> _connectionsActivity = Rxn<DashboardActivity>();
  final Rxn<DashboardActivity> _meetingsActivity = Rxn<DashboardActivity>();
  final Rxn<DashboardActivity> _referralsActivity = Rxn<DashboardActivity>();

  // ================= FETCH =================
  Future<void> fetchDashboard(NetworkType type) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final model = await _service.getDashboard(type);

      // global counts
      _counts.value = model.data.counts;

      // cache per type
      switch (type) {
        case NetworkType.checkins:
          _checkinsActivity.value = model.data.activity;
          break;

        case NetworkType.connections:
          _connectionsActivity.value = model.data.activity;
          break;

        case NetworkType.meetings:
          _meetingsActivity.value = model.data.activity;
          break;

        case NetworkType.referrals:
          _referralsActivity.value = model.data.activity;
          break;

        default:
          break;
      }
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  // ================= REFRESH =================
  Future<void> refreshDashboard(NetworkType type) async {
    switch (type) {
      case NetworkType.checkins:
        _checkinsActivity.value = null;
        break;
      case NetworkType.connections:
        _connectionsActivity.value = null;
        break;
      case NetworkType.meetings:
        _meetingsActivity.value = null;
        break;
      case NetworkType.referrals:
        _referralsActivity.value = null;
        break;
      default:
        break;
    }

    await fetchDashboard(type);
  }

  // ================= GETTERS =================

  List<CheckInModel> get checkins {
    final data = _checkinsActivity.value?.data;
    if (data == null) return [];
    return data.cast<CheckInModel>();
  }

  List<ConnectionModel> get connections {
    final data = _connectionsActivity.value?.data;
    if (data == null) return [];
    return data.cast<ConnectionModel>();
  }

  List<dynamic> get meetings {
    final data = _meetingsActivity.value?.data;
    if (data == null) return [];
    return data;
  }

  List<ReferralModel> get referrals {
    final data = _referralsActivity.value?.data;
    if (data == null) return [];
    return data.cast<ReferralModel>();
  }

  // ================= STATE HELPERS =================

  bool hasData(NetworkType type) {
    switch (type) {
      case NetworkType.checkins:
        return _checkinsActivity.value?.data.isNotEmpty ?? false;

      case NetworkType.connections:
        return _connectionsActivity.value?.data.isNotEmpty ?? false;

      case NetworkType.meetings:
        return _meetingsActivity.value?.data.isNotEmpty ?? false;

      case NetworkType.referrals:
        return _referralsActivity.value?.data.isNotEmpty ?? false;

      default:
        return false;
    }
  }
}
