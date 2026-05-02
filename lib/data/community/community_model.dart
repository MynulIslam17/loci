import 'package:loci/core/enums/category_enum.dart';
import '../../core/utils/member_parse.dart';

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String members;
  final BusinessCategory category;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.members,
    required this.category,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      members: formatMembers(json['totalMembers'] ?? 0),
      category: BusinessCategory.fromString(json["category"])
    );
  }
}