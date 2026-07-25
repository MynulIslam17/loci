import 'package:loci/features/qr_code/data/models/my_qr_code_model.dart';
import 'package:loci/features/qr_code/data/repositories/qr_code_repository.dart';

/// Domain orchestration for QR. Controllers call this — never NetworkCaller.
class QrCodeService {
  final QrCodeRepository _repository;

  QrCodeService(this._repository);

  Future<MyQrModel> getMyQrCode() async {
    final body = await _repository.getMyQrCode();
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }
    return MyQrModel.fromJson(data);
  }
}
