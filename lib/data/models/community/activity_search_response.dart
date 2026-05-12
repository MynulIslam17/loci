import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/community/activity_model.dart';

class ActivitySearchResponse {
  final bool success;
  final String message;
  final List<ActivityModel> data;
  final PaginationMeta meta;

  ActivitySearchResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory ActivitySearchResponse.fromJson(Map<String, dynamic> json) {
    return ActivitySearchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ActivityModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}
