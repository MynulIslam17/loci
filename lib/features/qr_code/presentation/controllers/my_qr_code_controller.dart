import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/presentation/controllers/new_chat_controller.dart';
import 'package:loci/features/network/presentation/controllers/connections_controller.dart';
import 'package:loci/features/network/presentation/controllers/network_dashboard_controller.dart';
import 'package:loci/features/qr_code/data/models/my_qr_code_model.dart';
import 'package:loci/features/qr_code/domain/services/qr_code_service.dart';
import 'package:loci/features/qr_code/presentation/widgets/qr_screen_tab_bar.dart';
import 'package:loci/shared/widgets/qrcode_maker.dart';

/// UI → [MyQrCodeController] → [QrCodeService] → [QrCodeRepository] → API.
class MyQrCodeController extends GetxController {
  MyQrCodeController(this._service);

  final QrCodeService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final RxnString _errorMessage = RxnString();
  final Rxn<MyQrModel> _myQr = Rxn<MyQrModel>();
  final RxBool _isConnecting = false.obs;
  final Rx<QrScreenTab> _selectedTab = QrScreenTab.scan.obs;
  final RxBool _isSavingGallery = false.obs;

  String? _lastScannedCode;
  DateTime? _lastScanAt;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isConnecting => _isConnecting.value;
  QrScreenTab get selectedTab => _selectedTab.value;
  Rx<QrScreenTab> get selectedTabRx => _selectedTab;
  bool get isSavingGallery => _isSavingGallery.value;
  String? get errorMessage => _errorMessage.value;
  MyQrModel? get myQr => _myQr.value;
  String? get qrCodeValue => _myQr.value?.qrCode;

  bool get _isLoggedIn => Get.find<AuthController>().isLoggedIn;

  void changeTab(QrScreenTab tab) {
    if (_selectedTab.value == tab) return;
    _selectedTab.value = tab;
    if (tab == QrScreenTab.myQr) {
      ensureLoaded();
    }
  }

  /// Loads the user's QR once authenticated — call from the screen, not [onInit].
  Future<void> ensureLoaded() async {
    if (!_isLoggedIn) return;
    if (hasFetched || isInitialLoading || isRefreshing) return;
    await fetchMyQr();
  }

  Future<void> fetchMyQr({bool isRefresh = false}) async {
    if (!_isLoggedIn) return;
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;

    try {
      final model = await _service.getMyQrCode();
      if (!model.hasCode) {
        throw Exception('Your QR code is not available yet');
      }
      _myQr.value = model;
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> refreshMyQr() => fetchMyQr(isRefresh: true);

  Future<ConnectViaQrResult?> connectViaQr(String rawCode) async {
    if (!_isLoggedIn) return null;
    final code = rawCode.trim();
    if (code.isEmpty || _isConnecting.value) return null;

    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(seconds: 3)) {
      return null;
    }

    _lastScannedCode = code;
    _lastScanAt = now;
    _isConnecting.value = true;

    try {
      final result = await _service.connectViaQr(code);
      _errorMessage.value = null;

      if (result.isAlreadyConnected) {
        SnackbarService.info(result.message);
      } else {
        if (Get.isRegistered<ConnectionsController>()) {
          Get.find<ConnectionsController>().fetchConnections(isRefresh: true);
        }
        if (Get.isRegistered<NetworkDashboardController>()) {
          Get.find<NetworkDashboardController>().fetchDashboard(isRefresh: true);
        }
        if (Get.isRegistered<NewChatController>()) {
          Get.find<NewChatController>().markStale();
        }

        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SnackbarService.success(result.message);
        });
      }
      return result;
    } catch (e) {
      final errStr = AppErrorMessages.sanitize(e);
      final lowerErr = errStr.toLowerCase();

      if (lowerErr.contains('already connect') ||
          lowerErr.contains('already exist') ||
          lowerErr.contains('already friend') ||
          lowerErr.contains('already member')) {
        SnackbarService.info(errStr);
        return ConnectViaQrResult(
          message: errStr,
          isAlreadyConnected: true,
        );
      }

      SnackbarService.error(errStr);
      return null;
    } finally {
      _isConnecting.value = false;
    }
  }

  Future<void> saveQrToGallery(
    BuildContext context,
    String code,
    String? userName,
  ) async {
    if (_isSavingGallery.value) return;

    _isSavingGallery.value = true;
    try {
      await CustomQrCode.download(
        code,
        context: context,
        title: userName ?? 'My QR Code',
        subtitle: 'Scan to connect on Loci',
      );
      SnackbarService.success('QR code saved to gallery');
    } catch (e) {
      SnackbarService.error(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _isSavingGallery.value = false;
    }
  }

  void clear() {
    _myQr.value = null;
    _errorMessage.value = null;
    _lastScannedCode = null;
    _lastScanAt = null;
    _isConnecting.value = false;
    _selectedTab.value = QrScreenTab.scan;
    _isSavingGallery.value = false;
    _fetch.reset();
  }
}
