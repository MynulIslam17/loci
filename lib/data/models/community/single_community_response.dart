import '../busniess/my_business_list_model.dart';

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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
