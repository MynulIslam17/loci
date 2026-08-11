

import 'package:loci/shared/models/review_model.dart';
import 'package:loci/shared/models/pagination_model.dart';

class ReviewResponseModel {
  final bool success;
  final String message;
  final List<ReviewModel> reviews;
  final PaginationMeta meta;

  ReviewResponseModel({
    required this.success,
    required this.message,
    required this.reviews,
    required this.meta,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      reviews: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ReviewModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}