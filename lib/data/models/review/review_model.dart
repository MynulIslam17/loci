import 'package:loci/data/models/review/review_author_model.dart';

class ReviewModel {
  final String id;
  final ReviewAuthor author;
  final String businessId;
  final double rating;
  final String content;
  final String createdAt;
  final String updatedAt;

  ReviewModel({
    required this.id,
    required this.author,
    required this.businessId,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      author: ReviewAuthor.fromJson(json['author'] ?? {}),
      businessId: json['business'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}