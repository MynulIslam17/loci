import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/community/data/models/activity_model.dart';

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
