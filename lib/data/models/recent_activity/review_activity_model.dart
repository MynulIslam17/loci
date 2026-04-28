class ReviewActivityModel {
  final String name;
  final String business;
  final String review;
  final String businessLogo;
  final int rating;

  ReviewActivityModel({
    required this.name,
    required this.business,
    required this.review,
    required this.rating,
    required this.businessLogo,
  });

  factory ReviewActivityModel.fromJson(Map<String, dynamic> json) {
    return ReviewActivityModel(
      name: json['name'] ?? '',
      business: json['business'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating'] ?? 0,
      businessLogo: json['businessLogo'] ?? 0,
    );
  }
}