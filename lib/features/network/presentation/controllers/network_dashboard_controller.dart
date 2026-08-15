import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/network/data/models/checkin_item.dart';
import 'package:loci/features/network/data/models/dashboard_count.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

/// Dashboard stats and recent check-ins for [NetworkScreen].
class NetworkDashboardController extends GetxController {
  NetworkDashboardController(this._service, [HiveStorageService? storage])
      : _storage = storage ??
            (Get.isRegistered<HiveStorageService>()
                ? Get.find<HiveStorageService>()
                : null);

  final NetworkService _service;
  final HiveStorageService? _storage;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();
  StreamSubscription<void>? _reconnectSub;

  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<DashboardCounts> _counts = Rxn<DashboardCounts>();
  final RxList<CheckInModel> _checkins = <CheckInModel>[].obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  String? get errorMessage => _errorMessage.value;
  DashboardCounts? get counts => _counts.value;
  List<CheckInModel> get checkins => List.unmodifiable(_checkins);

  @override
  void onInit() {
    super.onInit();

    // Frame-0 instant load from Hive cache
    if (_storage != null) {
      final cachedCounts = _storage.getScreenData('network_counts_cache');
      if (cachedCounts != null) {
        _counts.value = DashboardCounts.fromJson(cachedCounts);
      }
      final cachedCheckins = _storage.getFeedList('network_checkins_cache');
      if (cachedCheckins.isNotEmpty) {
        _checkins.assignAll(
          cachedCheckins
              .map((e) => CheckInModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
      if (cachedCounts != null || cachedCheckins.isNotEmpty) {
        _fetch.endFirstPage(markFetched: true);
      }
    }

    if (Get.isRegistered<ConnectivityService>()) {
      _reconnectSub = Get.find<ConnectivityService>().onReconnect.listen((_) {
        fetchDashboard(isRefresh: true);
      });
    }

    fetchDashboard();
  }

  @override
  void onClose() {
    _reconnectSub?.cancel();
    super.onClose();
  }

  Future<void> fetchDashboard({bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    // Fast Offline Guard: short-circuit immediately if offline
    if (ConnectivityService.isCurrentOffline) {
      _fetch.endFirstPage(markFetched: true);
      return;
    }

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;

    try {
      final model = await _service.getDashboard(NetworkType.checkins);
      _counts.value = model.data.counts;
      _checkins.assignAll(
        model.data.activity.data.cast<CheckInModel>(),
      );
      _fetch.endFirstPage();

      if (_storage != null) {
        _storage.saveScreenData(
          'network_counts_cache',
          model.data.counts.toJson(),
        );
        _storage.saveFeedList(
          'network_checkins_cache',
          _checkins.map((c) => c.toJson()).toList(),
        );
      }
    } catch (e) {
      if (_counts.value == null && _checkins.isEmpty) {
        _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
      _fetch.endFirstPage(
        markFetched: hasFetched || _counts.value != null || _checkins.isNotEmpty,
      );
    }
  }

  Future<void> refreshDashboard() => fetchDashboard(isRefresh: true);
}
