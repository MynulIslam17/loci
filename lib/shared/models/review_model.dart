import 'package:loci/shared/models/review_author_model.dart';

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
    final dynamic author = json['author'];
    final dynamic business = json['business'];
    return ReviewModel(
      id: json['_id'] ?? '',
      // `author` is a populated object on the list endpoint but a bare id
      // string on the create-review response — handle both without crashing.
      author: author is Map
          ? ReviewAuthor.fromJson(Map<String, dynamic>.from(author))
          : ReviewAuthor(id: author?.toString() ?? '', name: '', avatar: ''),
      businessId: business is Map
          ? (business['_id']?.toString() ?? '')
          : (business?.toString() ?? ''),
      rating: (json['rating'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}