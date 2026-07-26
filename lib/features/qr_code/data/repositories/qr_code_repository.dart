import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// QR code data layer: remote HTTP via [NetworkCaller].
class QrCodeRepository {
  final NetworkCaller _network;

  QrCodeRepository(this._network);

  Future<Map<String, dynamic>> getMyQrCode() async {
    final res = await _network.getRequest(url: AppUrl.myQrCode);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Something went wrong');
    }
    return res.body!;
  }
}
