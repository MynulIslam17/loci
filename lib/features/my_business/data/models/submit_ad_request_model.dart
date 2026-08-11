import 'dart:io';

/// Payload for `POST /admin/ads/submit` (multipart fields + image file).
class SubmitAdRequestModel {
  SubmitAdRequestModel({
    required this.title,
    required this.endDate,
    required this.image,
    this.businessId,
    this.businessName,
    this.location,
    this.startDate,
  });

  final String title;

  /// The business the ad (and its spotlight credits) belongs to. Required by
  /// the backend for owners of more than one business — it 400s without it.
  final String? businessId;
  final String? businessName;
  final String? location;
  final DateTime? startDate;
  final DateTime endDate;
  final File image;

  Map<String, String> toFields() {
    final fields = <String, String>{
      'title': title,
      'endDate': endDate.toUtc().toIso8601String(),
    };
    if (businessId != null && businessId!.isNotEmpty) {
      fields['businessId'] = businessId!;
    }
    if (businessName != null && businessName!.isNotEmpty) {
      fields['businessName'] = businessName!;
    }
    if (location != null && location!.isNotEmpty) {
      fields['location'] = location!;
    }
    if (startDate != null) {
      fields['startDate'] = startDate!.toUtc().toIso8601String();
    }
    return fields;
  }
}
