class CommunityMemberUser {
  final String id;
  final String name;
  final String email;
  final String avatar;

  CommunityMemberUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory CommunityMemberUser.fromJson(Map<String, dynamic> json) {
    return CommunityMemberUser(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

class CommunityMemberModel {
  final String id;
  final String businessId;
  final CommunityMemberUser user;
  final String addedByEmail;
  final String addedVia;
  final DateTime joinedAt;

  CommunityMemberModel({
    required this.id,
    required this.businessId,
    required this.user,
    required this.addedByEmail,
    required this.addedVia,
    required this.joinedAt,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      id: json['_id']?.toString() ?? '',
      businessId: json['business']?.toString() ?? '',
      user: CommunityMemberUser.fromJson(json['user'] ?? {}),
      addedByEmail: json['addedByEmail'] ?? '',
      addedVia: json['addedVia'] ?? '',
      joinedAt: DateTime.tryParse(json['joinedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
