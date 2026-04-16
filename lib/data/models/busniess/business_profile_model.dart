class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final String phone;
  final String website;
  final String logo;

  final double rating;
  final int reviewCount;

  final List<String> photos;
  final List<String> attachments;

  final bool isActive;

  final OwnerModel owner;
  final CommunityModel community;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.phone,
    required this.website,
    required this.logo,
    required this.rating,
    required this.reviewCount,
    required this.photos,
    required this.attachments,
    required this.isActive,
    required this.owner,
    required this.community,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      logo: json['logo'] ?? '',

      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,

      photos: List<String>.from(json['photos'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),

      isActive: json['isActive'] ?? false,

      owner: OwnerModel.fromJson(json['owner'] ?? {}),
      community: CommunityModel.fromJson(json['communityId'] ?? {}),
    );
  }


  ///===== for update the model any specific part
  BusinessModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? location,
    String? phone,
    String? website,
    String? logo,
    double? rating,
    int? reviewCount,
    List<String>? photos,
    List<String>? attachments,
    bool? isActive,
    OwnerModel? owner,
    CommunityModel? community,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      photos: photos ?? this.photos,
      attachments: attachments ?? this.attachments,
      isActive: isActive ?? this.isActive,
      owner: owner ?? this.owner,
      community: community ?? this.community,
    );
  }
}





class OwnerModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String? phone;

  OwnerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    this.phone,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      phone: json['phone'],
    );
  }
}

class CommunityModel {
  final String id;
  final String name;
  final String qrCode;
  final int memberCount;

  CommunityModel({
    required this.id,
    required this.name,
    required this.qrCode,
    required this.memberCount,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      qrCode: json['qrCode'] ?? '',
      memberCount: json['memberCount'] ?? 0,
    );
  }
}
