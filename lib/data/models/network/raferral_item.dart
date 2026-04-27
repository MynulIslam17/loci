import 'package:loci/core/enums/referral_enum.dart';

class ReferralModel {
  final String id;
  final ReferralStatus status;
  final String fromName;
  final String fromCompany;
  final String toName;
  final String toCompany;
  final String message;
  final String date;

  ReferralModel({
    required this.id,
    required this.status,
    required this.fromName,
    required this.fromCompany,
    required this.toName,
    required this.toCompany,
    required this.message,
    required this.date,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] ?? '',
      status: ReferralStatus.fromString(json['status'] ?? ''),
      fromName: json['fromName'] ?? '',
      fromCompany: json['fromCompany'] ?? '',
      toName: json['toName'] ?? '',
      toCompany: json['toCompany'] ?? '',
      message: json['message'] ?? '',
      date: json['date'] ?? '',
    );
  }

  DateTime get dateTime=>DateTime.parse(date);


}