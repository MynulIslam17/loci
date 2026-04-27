class ReviewActivityModel {
  final String name;
  final String business;
  final String review;
  final int rating;

  ReviewActivityModel({
    required this.name,
    required this.business,
    required this.review,
    required this.rating,
  });

  factory ReviewActivityModel.fromJson(Map<String, dynamic> json) {
    return ReviewActivityModel(
      name: json['name'] ?? '',
      business: json['business'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }
}