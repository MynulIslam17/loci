class ReviewAuthor {
  final String id;
  final String name;
  final String avatar;

  ReviewAuthor({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) {
    return ReviewAuthor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}