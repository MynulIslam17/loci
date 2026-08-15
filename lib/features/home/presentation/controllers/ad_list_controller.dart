import 'dart:async';
import 'package:get/get.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/my_business/data/models/ad_item_model.dart';

class AdListController extends GetxController {
  AdListController(this._service, [HiveStorageService? storage])
      : _storage = storage ??
            (Get.isRegistered<HiveStorageService>()
                ? Get.find<HiveStorageService>()
                : (HiveStorageService.isInitialized
                    ? HiveStorageService.instance
                    : null));

  final HomeService _service;
  final HiveStorageService? _storage;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();
  StreamSubscription<void>? _reconnectSub;

  final errorMessage = RxnString();
  final ads = <AdItemModel>[].obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;

  @override
  void onInit() {
    super.onInit();

    // Frame-0 instant load from Hive cache
    if (_storage != null) {
      final cached = _storage.getFeedList('home_feed_ads');
      if (cached.isNotEmpty) {
        ads.assignAll(
          cached.map((e) => AdItemModel.fromJson(e)).toList(),
        );
        _fetch.endFirstPage(markFetched: true);
      }
    }

    if (Get.isRegistered<ConnectivityService>()) {
      _reconnectSub = Get.find<ConnectivityService>().onReconnect.listen((_) {
        fetchAds(showErrorToast: false, isRefresh: true);
      });
    }

    fetchAds(showErrorToast: false);
  }

  @override
  void onClose() {
    _reconnectSub?.cancel();
    super.onClose();
  }

  Future<void> fetchAds({bool showErrorToast = true, bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    // Fast Offline Guard: short-circuit immediately if offline
    if (ConnectivityService.isCurrentOffline) {
      _fetch.endFirstPage(markFetched: true);
      return;
    }

    _fetch.beginFirstPage(isRefresh: isRefresh);
    errorMessage.value = null;

    try {
      final result = await _service.getAds();
      ads.assignAll(result);
      _fetch.endFirstPage();

      if (_storage != null && result.isNotEmpty) {
        _storage.saveFeedList(
          'home_feed_ads',
          result.map((a) => a.toJson()).toList(),
        );
      }
    } catch (e) {
      if (ads.isEmpty) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
        if (showErrorToast &&
            errorMessage.value != null &&
            errorMessage.value!.isNotEmpty) {
          SnackbarService.error(errorMessage.value!);
        }
      }
      _fetch.endFirstPage(markFetched: hasFetched || ads.isNotEmpty);
    }
  }
}
