class MyBusinessResponseModel {
  final bool success;
  final String message;
  final List<BusinessModel> data;

  MyBusinessResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MyBusinessResponseModel.fromJson(Map<String, dynamic> json) {
    return MyBusinessResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
          .map((e) => BusinessModel.fromJson(e))
          .toList()
          : [],
    );
  }
}

class BusinessModel {
  final String id;
  final String name;
  final String? category;
  final String? description;
  final String? logo;

  BusinessModel({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.logo,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'], // nullable
      description: json['description'], // nullable
      logo: json['logo'], // nullable
    );
  }
}