import 'package:loci/core/enums/metting_enum.dart';

import '../../../core/utils/time_parser.dart';

class MeetingModel {
  final String id;
  final MeetingStatus status;
  final String fromName;
  final String fromCompany;
  final String toName;
  final String toCompany;
  final String location;
  final String time;
  final String message;
  final String date;

  MeetingModel({
    required this.id,
    required this.status,
    required this.fromName,
    required this.fromCompany,
    required this.toName,
    required this.toCompany,
    required this.location,
    required this.time,
    required this.message,
    required this.date,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] ?? '',
      status: MeetingStatus.fromString(json['status']),
      fromName: json['fromName'] ?? '',
      fromCompany: json['fromCompany'] ?? '',
      toName: json['toName'] ?? '',
      toCompany: json['toCompany'] ?? '',
      location: json['location'] ?? '',
      time: json['time'] ?? '',
      message: json['message'] ?? '',
      date: json['date'] ?? '',
    );
  }


  DateTime get dateTime => DateTime.parse(date);

  String get formatedTime=>formatUtcToLocalTime(time);


}