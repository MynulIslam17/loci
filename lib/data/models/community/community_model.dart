import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/enums/community_role.dart';

import '../../../core/utils/member_parse.dart';


class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String members;
  final String qrCode;
  final BusinessCategory category;
  final CommunityRole ? role;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.members,
    required this.qrCode,
    required this.category,
     this.role,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      qrCode: json['qrCode'] ?? '',
      members: formatMembers(json['totalMembers'] ?? 0),
      category: BusinessCategory.fromString(json["category"]),
      role: json['role'] != null
          ? CommunityRole.fromString(json['role'])
          : null,

    );
  }
}
