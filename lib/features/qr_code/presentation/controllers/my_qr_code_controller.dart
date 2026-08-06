import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/qr_code/data/models/my_qr_code_model.dart';
import 'package:loci/features/qr_code/domain/services/qr_code_service.dart';

/// UI → [MyQrCodeController] → [QrCodeService] → [QrCodeRepository] → API.
class MyQrCodeController extends GetxController {
  MyQrCodeController(this._service);

  final QrCodeService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final RxnString _errorMessage = RxnString();
  final Rxn<MyQrModel> _myQr = Rxn<MyQrModel>();
  final RxBool _isConnecting = false.obs;

  String? _lastScannedCode;
  DateTime? _lastScanAt;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isConnecting => _isConnecting.value;
  String? get errorMessage => _errorMessage.value;
  MyQrModel? get myQr => _myQr.value;
  String? get qrCodeValue => _myQr.value?.qrCode;

  bool get _isLoggedIn => Get.find<AuthController>().isLoggedIn;

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

  Future<bool> connectViaQr(String rawCode) async {
    if (!_isLoggedIn) return false;
    final code = rawCode.trim();
    if (code.isEmpty || _isConnecting.value) return false;

    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(seconds: 3)) {
      return false;
    }

    _lastScannedCode = code;
    _lastScanAt = now;
    _isConnecting.value = true;

    try {
      final result = await _service.connectViaQr(code);
      _errorMessage.value = null;
      SnackbarService.success(result.message);
      return true;
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
      return false;
    } finally {
      _isConnecting.value = false;
    }
  }

  void clear() {
    _myQr.value = null;
    _errorMessage.value = null;
    _lastScannedCode = null;
    _lastScanAt = null;
    _isConnecting.value = false;
    _fetch.reset();
  }
}
