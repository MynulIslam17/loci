class CreateBusinessResponseModel {
  final bool success;
  final String message;
  final CreatedBusinessModel? data;

  CreateBusinessResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateBusinessResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateBusinessResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] is Map<String, dynamic>
          ? CreatedBusinessModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CreatedBusinessModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final String phone;
  final String? website;
  final String? logo;
  final String? claimStatus;

  CreatedBusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.phone,
    this.website,
    this.logo,
    this.claimStatus,
  });

  factory CreatedBusinessModel.fromJson(Map<String, dynamic> json) {
    return CreatedBusinessModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] as String?,
      logo: json['logo'] as String?,
      claimStatus: json['claimStatus'] as String?,
    );
  }

  Map<String, dynamic> toClaimDisplayArgs() => {
        'name': name,
        'location': location,
        'phone': phone,
        'website': website,
        'description': description,
        'logo': logo,
        'businessId': id,
        'category': category,
      };
}
