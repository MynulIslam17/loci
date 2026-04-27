import '../common/paginatation_model.dart';

class RecentActivityResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final PaginationMeta meta;

  RecentActivityResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory RecentActivityResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return RecentActivityResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data']['data'] as List? ?? [])
          .map((e) => fromJsonT(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['data']['meta'] ?? {}),
    );
  }
}