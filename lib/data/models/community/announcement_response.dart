import 'package:loci/data/models/common/paginatation_model.dart';

import 'announcement_model.dart';

class AnnouncementResponse {
  final bool success;
  final String message;
  final List<AnnouncementModel> data;
  final PaginationMeta meta;

  AnnouncementResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory AnnouncementResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => AnnouncementModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {})
    );
  }
}