import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../data/models/user/my_qr_code_model.dart';

class GetMyQrCodeController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  MyQrModel? _myQrCode;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MyQrModel? get myQrCode => _myQrCode;

  // ================= FETCH =================
  Future<void> getMyQrCode({bool forceRefresh = false}) async {
    // ✅ cache check
   // if (_myQrCode != null && !forceRefresh) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.myQrCode,
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!["data"];

        if (data != null) {
          _myQrCode = MyQrModel.fromJson(data);
        } else {
          _errorMessage = "Invalid response format";
        }
      } else {
        _errorMessage = response.errorMessage ?? "Something went wrong";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ================= REFRESH =================
  Future<void> refreshQr() async {
    _myQrCode = null;
    await getMyQrCode(forceRefresh: true);
  }
}
