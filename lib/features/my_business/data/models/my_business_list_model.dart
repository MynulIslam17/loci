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
  final String? location;
  final List<String> photos;

  BusinessModel({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.logo,
    this.location,
    this.photos = const [],
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      description: json['description'],
      logo: json['logo'],
      location: json['location']?.toString(),
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : const [],
    );
  }

  BusinessModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? logo,
    String? location,
    List<String>? photos,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      location: location ?? this.location,
      photos: photos ?? this.photos,
    );
  }
}
