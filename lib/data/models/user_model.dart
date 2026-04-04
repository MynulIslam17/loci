class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? avatar;
  final String? phone;
  final String? dateOfBirth;
  final String? zipCode;
  final String? lastLoginAt;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.avatar,
    this.phone,
    this.dateOfBirth,
    this.zipCode,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      avatar: json['avatar'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      zipCode: json['zipCode'],
      lastLoginAt: json['lastLoginAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'avatar': avatar,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'zipCode': zipCode,
      'lastLoginAt': lastLoginAt,
      'createdAt': createdAt,
    };
  }
}