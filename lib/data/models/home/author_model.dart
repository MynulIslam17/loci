class AuthorModel {
  final String id;
  final String name;
  final String avatar;

  const AuthorModel({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) => AuthorModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: (json['name'] as String?) ?? '',
        avatar: json['avatar'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'avatar': avatar,
      };
}
