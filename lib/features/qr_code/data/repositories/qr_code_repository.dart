import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// QR code data layer: remote HTTP via [NetworkCaller].
class QrCodeRepository {
  QrCodeRepository(this._network);

  final NetworkCaller _network;

  Future<Map<String, dynamic>> getMyQrCode() async {
    final res = await _network.getRequest(url: AppUrl.myQrCode);
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to load your QR code',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> connectViaQr({required String qrCode}) async {
    final res = await _network.postRequest(
      url: AppUrl.connectViaQr,
      body: {'qrCode': qrCode},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ??
            res.errorMessage ??
            'Failed to connect',
      );
    }
    return res.body!;
  }
}
