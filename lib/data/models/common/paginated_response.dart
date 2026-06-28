import 'package:loci/data/models/common/paginatation_model.dart';

class PaginatedResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PaginatedResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList() ??
          [],
      meta: PaginationMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}