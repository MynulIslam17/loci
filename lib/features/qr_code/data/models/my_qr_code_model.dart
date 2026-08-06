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
  final bool isAlreadyConnected;
  final Map<String, dynamic>? data;

  const ConnectViaQrResult({
    required this.message,
    this.isAlreadyConnected = false,
    this.data,
  });

  factory ConnectViaQrResult.fromJson(Map<String, dynamic> json) {
    final msg = json['message']?.toString() ?? 'Connection added successfully';
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    final lowerMsg = msg.toLowerCase();
    final alreadyInBody = json['isAlreadyConnected'] == true ||
        dataMap?['isAlreadyConnected'] == true ||
        dataMap?['alreadyConnected'] == true ||
        lowerMsg.contains('already connect') ||
        lowerMsg.contains('already exist') ||
        lowerMsg.contains('already friend') ||
        lowerMsg.contains('already member');

    return ConnectViaQrResult(
      message: msg,
      isAlreadyConnected: alreadyInBody,
      data: dataMap,
    );
  }
}
