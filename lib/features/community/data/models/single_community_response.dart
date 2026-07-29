import 'package:loci/features/my_business/data/models/my_business_list_model.dart';

class SingleCommunityResponse {
  final bool success;
  final String message;
  final CommunityModel data;

  SingleCommunityResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SingleCommunityResponse.fromJson(Map<String, dynamic> json) {
    return SingleCommunityResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CommunityModel.fromJson(json['data'] ?? {}),
    );
  }
}

class CommunityModel {
  final String id;
  final BusinessModel business;
  final String name;
  final String description;
  final String qrCode;
  final int memberCount;
  final bool isActive;
  final String? ownerUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommunityModel({
    required this.id,
    required this.business,
    required this.name,
    required this.description,
    required this.qrCode,
    required this.memberCount,
    required this.isActive,
    this.ownerUserId,
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['_id'] ?? '',
      business: BusinessModel.fromJson(json['business'] ?? {}),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      qrCode: json['qrCode'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      ownerUserId: _parseOwnerUserId(json),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  static String? _parseOwnerUserId(Map<String, dynamic> json) {
    final owner = json['owner'];
    if (owner is Map) {
      final id = owner['_id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    } else if (owner is String && owner.isNotEmpty) {
      return owner;
    }

    final ownerId = json['ownerId']?.toString();
    if (ownerId != null && ownerId.isNotEmpty) return ownerId;

    final business = json['business'];
    if (business is Map<String, dynamic>) {
      final businessOwner = business['owner'];
      if (businessOwner is Map) {
        final id = businessOwner['_id']?.toString();
        if (id != null && id.isNotEmpty) return id;
      } else if (businessOwner is String && businessOwner.isNotEmpty) {
        return businessOwner;
      }
      final userId = business['userId']?.toString();
      if (userId != null && userId.isNotEmpty) return userId;
    }

    final createdBy = json['createdBy'];
    if (createdBy is Map) {
      final id = createdBy['_id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }

    return null;
  }
}
