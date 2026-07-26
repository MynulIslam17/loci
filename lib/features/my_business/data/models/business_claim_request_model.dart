import 'dart:io';

class BusinessClaimRequestModel {
  final String? placeId;
  final String? businessId;
  final String category;
  final String? message;
  final List<File> proof;

  BusinessClaimRequestModel({
    this.placeId,
    this.businessId,
    required this.category,
    this.message,
    required this.proof,
  }) : assert(
         (placeId != null && placeId.isNotEmpty) ^
             (businessId != null && businessId.isNotEmpty),
         'Provide either placeId or businessId',
       );

  Map<String, String> toFields() {
    final map = <String, String>{'category': category};

    if (placeId != null && placeId!.isNotEmpty) {
      map['placeId'] = placeId!;
    }
    if (businessId != null && businessId!.isNotEmpty) {
      map['businessId'] = businessId!;
    }
    if (message != null && message!.trim().isNotEmpty) {
      map['message'] = message!.trim();
    }

    return map;
  }

  Map<String, List<File>> toMultiFileMap() => {'proof': proof};
}
