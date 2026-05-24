class VoterModel {
  final String userId;
  final String name;
  final String avatar;

  const VoterModel({
    required this.userId,
    required this.name,
    required this.avatar,
  });

  factory VoterModel.fromJson(Map<String, dynamic> json) => VoterModel(
        userId: json['userId'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'avatar': avatar,
      };
}
