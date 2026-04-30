
import 'owner_model.dart';

class BrowseBusinessModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final String phone;
  final String website;
  final String logo;

  final List<String> photos;

  final double rating;
  final int reviewCount;

  final bool isActive;

  final String createdAt;
  final String updatedAt;

  final OwnerModel? owner;

  BrowseBusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.phone,
    required this.website,
    required this.logo,
    required this.photos,
    required this.rating,
    required this.reviewCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
  });

  factory BrowseBusinessModel.fromJson(Map<String, dynamic> json) {
    return BrowseBusinessModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      logo: json['logo'] ?? '',

      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : [],

      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,

      isActive: json['isActive'] ?? false,

      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',

      owner: json['owner'] != null
          ? OwnerModel.fromJson(json['owner'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'description': description,
      'location': location,
      'phone': phone,
      'website': website,
      'logo': logo,
      'photos': photos,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'owner': owner?.toJson(),
    };
  }
}