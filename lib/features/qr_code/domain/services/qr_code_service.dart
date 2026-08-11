import 'package:loci/features/qr_code/data/models/my_qr_code_model.dart';
import 'package:loci/features/qr_code/data/repositories/qr_code_repository.dart';

/// Domain orchestration for QR. Controllers call this — never [NetworkCaller].
class QrCodeService {
  QrCodeService(this._repository);

  final QrCodeRepository _repository;

  Future<MyQrModel> getMyQrCode() async {
    final body = await _repository.getMyQrCode();
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return MyQrModel.fromJson(data);
    }
    if (data is Map) {
      return MyQrModel.fromJson(Map<String, dynamic>.from(data));
    }
    if (body['qrCode'] != null || body['qr'] != null) {
      return MyQrModel.fromJson(body);
    }
    throw Exception('Invalid QR response format');
  }

  Future<ConnectViaQrResult> connectViaQr(String qrCode) async {
    final trimmed = qrCode.trim();
    if (trimmed.isEmpty) {
      throw Exception('Invalid QR code');
    }
    final body = await _repository.connectViaQr(qrCode: trimmed);
    return ConnectViaQrResult.fromJson(body);
  }
}
