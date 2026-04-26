// ─────────────────────────────────────────
// connection model.dart
// ─────────────────────────────────────────
class ConnectionModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String organization;
  final String connectedAt;

  ConnectionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.organization,
    required this.connectedAt,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      organization: json['organization'] ?? '',
      connectedAt:json["connectedAt"] ?? "",
    );
  }
}