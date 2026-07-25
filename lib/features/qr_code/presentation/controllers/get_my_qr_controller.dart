import 'package:get/get.dart';
import 'package:loci/features/qr_code/data/models/my_qr_code_model.dart';
import 'package:loci/features/qr_code/domain/services/qr_code_service.dart';

class GetMyQrCodeController extends GetxController {
  GetMyQrCodeController(this._service);

  final QrCodeService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<MyQrModel> _myQrCode = Rxn<MyQrModel>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  MyQrModel? get myQrCode => _myQrCode.value;

  /// Loads the current user's QR code.
  ///
  /// The QR is stable for a user, so once loaded it is served from memory for
  /// the rest of the session — repeat screen visits won't hit the network.
  /// Pass [forceRefresh] (or call [refreshQr]) to fetch again on demand.
  Future<void> getMyQrCode({bool forceRefresh = false}) async {
    // Serve the cached value unless an explicit refresh was requested.
    if (!forceRefresh && _myQrCode.value != null) return;

    // Ignore overlapping calls (e.g. a rebuild firing while one is in flight).
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      _myQrCode.value = await _service.getMyQrCode();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshQr() async {
    _myQrCode.value = null;
    await getMyQrCode(forceRefresh: true);
  }

  /// Drops the cached QR so a different signed-in user never sees it.
  /// Called on logout.
  void clear() {
    _myQrCode.value = null;
    _errorMessage.value = null;
    _isLoading.value = false;
  }
}
