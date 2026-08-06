class MyQrModel {
  final String qrCode;

  const MyQrModel({required this.qrCode});

  bool get hasCode => qrCode.trim().isNotEmpty;

  factory MyQrModel.fromJson(Map<String, dynamic> json) {
    final code = json['qrCode'] ?? json['qr'] ?? json['code'] ?? '';
    return MyQrModel(qrCode: code.toString());
  }
}

class ConnectViaQrResult {
  final String message;

  const ConnectViaQrResult({required this.message});

  factory ConnectViaQrResult.fromJson(Map<String, dynamic> json) {
    return ConnectViaQrResult(
      message: json['message']?.toString() ?? 'Connection added successfully',
    );
  }
}
