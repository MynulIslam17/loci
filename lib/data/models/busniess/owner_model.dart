class OwnerModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String phone;

  OwnerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.phone,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'phone': phone,
    };
  }
}