import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Global service tracking internet connectivity state reactively across the app.
class ConnectivityService extends GetxService {
  static ConnectivityService get instance =>
      Get.isRegistered<ConnectivityService>()
          ? Get.find<ConnectivityService>()
          : Get.put(ConnectivityService(), permanent: true);

  static bool get isCurrentOnline {
    if (!Get.isRegistered<ConnectivityService>()) return true;
    return Get.find<ConnectivityService>().isOnline.value;
  }

  static bool get isCurrentOffline {
    if (!Get.isRegistered<ConnectivityService>()) return false;
    return Get.find<ConnectivityService>().isOffline.value;
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool isOnline = true.obs;
  final RxBool isOffline = false.obs;
  final RxBool justReconnected = false.obs;
  final RxBool isAppReady = false.obs;

  final _reconnectStreamCtrl = StreamController<void>.broadcast();
  Stream<void> get onReconnect => _reconnectStreamCtrl.stream;

  Timer? _reconnectTimer;

  @override
  void onInit() {
    super.onInit();
    _checkInitial();
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkInitial() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _processResults(results);
    } catch (_) {
      isOnline.value = true;
      isOffline.value = false;
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _processResults(results);
  }

  Set<ConnectivityResult> _previousResults = {};

  void _processResults(List<ConnectivityResult> results) {
    final currentSet = results.toSet();
    final hasNoConnection = results.contains(ConnectivityResult.none) && results.length == 1;
    final nowOffline = hasNoConnection || results.isEmpty;

    if (nowOffline) {
      if (isOnline.value) {
        // Transition from online -> offline
        isOnline.value = false;
        isOffline.value = true;
        justReconnected.value = false;
      }
    } else {
      final wasOffline = isOffline.value;
      final interfaceChanged = _previousResults.isNotEmpty &&
          !_previousResults.contains(ConnectivityResult.none) &&
          !_setEquals(_previousResults, currentSet);

      if (wasOffline || interfaceChanged) {
        // Transition from offline -> online OR switched interface (Wi-Fi <-> Mobile Data).
        // Flag reconnect first so the banner can turn green in the same
        // frame instead of collapsing, then sliding back in.
        justReconnected.value = true;
        isOnline.value = true;
        isOffline.value = false;

        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(milliseconds: 1400), () {
          justReconnected.value = false;
        });

        _reconnectStreamCtrl.add(null);
      }
    }
    _previousResults = currentSet;
  }

  bool _setEquals(Set<ConnectivityResult> a, Set<ConnectivityResult> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  /// Manually checks if the device can actually reach the internet.
  Future<bool> checkActualInternet() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none) && results.length == 1) {
        isOnline.value = false;
        isOffline.value = true;
        return false;
      }
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      final connected = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
      isOnline.value = connected;
      isOffline.value = !connected;
      return connected;
    } catch (_) {
      isOnline.value = false;
      isOffline.value = true;
      return false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _reconnectTimer?.cancel();
    _reconnectStreamCtrl.close();
    super.onClose();
  }
}
