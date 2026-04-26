class MyQrModel {
  final String myQrCode;

  MyQrModel({required this.myQrCode});

  factory MyQrModel.fromJson(Map<String, dynamic> json) {
    return MyQrModel(myQrCode: json["qrCode"] ?? '');
  }
}
