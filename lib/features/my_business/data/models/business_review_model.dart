import 'package:loci/shared/models/pagination_model.dart';

class ReviewModel {
  final String id;
  final ReviewAuthor author;
  final String businessId;
  final int rating;
  final String content;
  final String createdAt;
  final String updatedAt;

  const ReviewModel({
    required this.id,
    required this.author,
    required this.businessId,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['_id'] ?? '',
    author: ReviewAuthor.fromJson(json['author']),
    businessId: json['business'] ?? '',
    rating: json['rating'] ?? 0,
    content: json['content'] ?? '',
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
  );
}

class ReviewAuthor {
  final String id;
  final String name;
  final String avatar;

  const ReviewAuthor({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) => ReviewAuthor(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    avatar: json['avatar'] ?? '',
  );
}

class ReviewResponse {
  final List<ReviewModel> data;
  final PaginationMeta meta;

  const ReviewResponse({required this.data, required this.meta});

  factory ReviewResponse.fromJson(Map<String, dynamic> json) => ReviewResponse(
    data: (json['data'] as List<dynamic>? ?? [])
        .map((e) => ReviewModel.fromJson(e))
        .toList(),
    meta: PaginationMeta.fromJson(json['meta']),
  );
}
